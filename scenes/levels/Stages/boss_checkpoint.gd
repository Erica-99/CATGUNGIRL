extends Node

@export var checkpoint_player: CharacterBody3D
@export var checkpoint_boss: Node
@export var checkpoint_spawn: Marker3D

## phase number shown to player
@export_range(2, 20, 1) var checkpoint_phase_number: int = 2
@onready var stage_root: Node = get_parent()

func _ready() -> void:
	if stage_root == null or checkpoint_boss == null:
		return
	
	EventManager.brainjar_phase_started.connect(_on_brainjar_phase_started)
	call_deferred("_restore_boss_checkpoint")
	
func _on_brainjar_phase_started(phase_index: int) -> void:
	if phase_index != checkpoint_phase_number - 1:
		return
	
	var level_path: String = stage_root.scene_file_path
	# keep original checkpoint on repeated retries
	if CheckpointManager.has_checkpoint_for(level_path):
		return
	
	if checkpoint_player == null or checkpoint_spawn == null:
		return
	
	var boss_health_component: HealthComponent = \
		checkpoint_boss.get("health_component") as HealthComponent
	
	if boss_health_component == null:
		return
	
	CheckpointManager.save_checkpoint(level_path, checkpoint_spawn.global_position, {"kind": "brain_jar", "boss_phase_index": phase_index, "boss_health": boss_health_component.current_health,})

func _restore_boss_checkpoint() -> void:
	var level_path: String = stage_root.scene_file_path
	
	var checkpoint: Dictionary = \
		CheckpointManager.get_pending_checkpoint(level_path)
	
	if checkpoint.is_empty():
		return
	
	var state: Dictionary = checkpoint.get("state", {})
	
	if state.get("kind", "") != "brain_jar":
		return
	
	if checkpoint_player == null:
		return
	
	if !checkpoint_boss.has_method("restore_checkpoint"):
		return
	
	checkpoint_player.global_position = checkpoint["spawn_position"]
	checkpoint_player.velocity = Vector3.ZERO
	
	var restored: bool = checkpoint_boss.call("restore_checkpoint", state)
	
	if restored:
		CheckpointManager.finish_restore(level_path)
