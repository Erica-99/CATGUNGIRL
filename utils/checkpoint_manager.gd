extends Node

var checkpoint_scene_path: String = ""
var checkpoint_position: Vector3 = Vector3.ZERO
var checkpoint_state: Dictionary = {}
var checkpoint_unlocked_guns: Array[int] = []
var pending_restore_scene_path: String = ""

func save_checkpoint(
	scene_path: String,
	spawn_position: Vector3,
	state: Dictionary = {}) -> void:
	checkpoint_scene_path = scene_path
	checkpoint_position = spawn_position
	checkpoint_state = state.duplicate(true)
	checkpoint_unlocked_guns.assign(Globals.unlocked_guns)
	print("Checkpoint saved: ", scene_path)

func has_checkpoint_for(scene_path: String) -> bool:
	return checkpoint_scene_path != "" and checkpoint_scene_path == scene_path

## called before loading the level again
func prepare_retry(scene_path: String) -> void:
	pending_restore_scene_path = ""
	
	if !has_checkpoint_for(scene_path):
		return
	
	# restore globals before the new Player and guns initialise
	Globals.unlocked_guns.assign(checkpoint_unlocked_guns)
	pending_restore_scene_path = scene_path

## called by the loaded level to retrieve checkpoint
func get_pending_checkpoint(scene_path: String) -> Dictionary:
	if pending_restore_scene_path == "":
		return {}
	
	if pending_restore_scene_path != scene_path:
		return {}
	
	return {"spawn_position": checkpoint_position, "state": checkpoint_state.duplicate(true),}

## finish restoring without deleting checkpoint
func finish_restore(scene_path: String) -> void:
	if pending_restore_scene_path == scene_path:
		pending_restore_scene_path = ""

func clear_checkpoint() -> void:
	checkpoint_scene_path = ""
	checkpoint_position = Vector3.ZERO
	checkpoint_state.clear()
	checkpoint_unlocked_guns.clear()
	pending_restore_scene_path = ""
