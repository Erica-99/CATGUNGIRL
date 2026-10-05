extends Node

@export var checkpoint_player: CharacterBody3D
@export var checkpoint_spawn: Marker3D

## The sequence whose completion saves the checkpoint
@export var checkpoint_sequence: Node
@onready var stage_root: Node = get_parent()
@export var intro_animation_player: AnimationPlayer
@export var intro_animation_name: StringName = &"Intro"

func _ready() -> void:
	if checkpoint_sequence == null:
		return
	
	if !checkpoint_sequence.has_signal("finished"):
		return
	
	checkpoint_sequence.connect("finished", _on_checkpoint_sequence_finished)
	call_deferred("_restore_tutorial_checkpoint")

func _on_checkpoint_sequence_finished() -> void:
	# let normal completion callbacks run before saving
	call_deferred("_save_tutorial_checkpoint")

func _save_tutorial_checkpoint() -> void:
	if checkpoint_player == null or checkpoint_spawn == null:
		return
	
	var level_path: String = stage_root.scene_file_path
	
	if CheckpointManager.has_checkpoint_for(level_path):
		return
	
	if !is_instance_valid(checkpoint_sequence):
		return
	
	if !stage_root.is_ancestor_of(checkpoint_sequence):
		return
	
	var completed_paths: Array[NodePath] = [stage_root.get_path_to(checkpoint_sequence)]
	CheckpointManager.save_checkpoint(level_path, checkpoint_spawn.global_position, {"kind": "tutorial", "completed_tutorial_paths": completed_paths, "player_has_gun": bool(checkpoint_player.get("has_gun")),})

func _restore_tutorial_checkpoint() -> void:
	var level_path: String = stage_root.scene_file_path
	var checkpoint: Dictionary = \
		CheckpointManager.get_pending_checkpoint(level_path)
	
	if checkpoint.is_empty():
		return
	
	var state: Dictionary = checkpoint.get("state", {})
	
	if state.get("kind", "") != "tutorial":
		return
	
	if checkpoint_player == null:
		return
	
	checkpoint_player.global_position = checkpoint["spawn_position"]
	checkpoint_player.velocity = Vector3.ZERO
	_restore_intro_pose()
	var restored_has_gun: bool = bool(state.get("player_has_gun", false))
	checkpoint_player.set("has_gun", restored_has_gun)
	checkpoint_player.call("_set_gun_enabled", restored_has_gun)
	CheckpointManager.finish_restore(level_path)

func _exit_tree() -> void:
	TutorialManager.stop()

func _restore_intro_pose() -> void:
	if intro_animation_player == null:
		return
	
	if !intro_animation_player.has_animation(intro_animation_name):
		return
	
	var intro_animation: Animation = \
		intro_animation_player.get_animation(intro_animation_name)
	
	intro_animation_player.stop(true)
	intro_animation_player.assigned_animation = intro_animation_name
	intro_animation_player.seek(intro_animation.length, true, true)
