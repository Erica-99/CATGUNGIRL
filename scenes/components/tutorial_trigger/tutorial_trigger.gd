extends Node

signal finished

@export var sequence_name: String

@export var steps: Array[TutorialStep] = []
@export var autostart: bool = true

## OPTIONAL: Choose which door to unlock when tutorial steps are completed
@export var door_to_unlock: Node3D

var _restored_completed: bool = false

func _ready() -> void:
	if _restore_completed_sequence():
		call_deferred("_unlock_door")
		return
	
	EventManager.initiate_tutorial_sequence.connect(_on_tutorial_sequence_triggered)
	if autostart:
		start()

func _on_tutorial_sequence_triggered(requested_sequence_name: String) -> void:
	if requested_sequence_name == sequence_name:
		start()

func start() -> void:
	if _restored_completed:
		return
	
	if !TutorialManager.sequence_finished.is_connected(_on_sequence_finished):
		TutorialManager.sequence_finished.connect(_on_sequence_finished, CONNECT_ONE_SHOT)
	
	TutorialManager.start(steps)

func _on_sequence_finished() -> void:
	finished.emit()
	_unlock_door()

func _unlock_door() -> void:
	if door_to_unlock != null:
		EventManager.set_door_openable_state.emit(door_to_unlock, true)

func _restore_completed_sequence() -> bool:
	var ancestor: Node = get_parent()
	
	while ancestor != null:
		if ancestor.scene_file_path != "":
			var checkpoint: Dictionary = \
				CheckpointManager.get_pending_checkpoint(ancestor.scene_file_path)
			
			if !checkpoint.is_empty():
				var state: Dictionary = checkpoint.get("state", {})
				
				if state.get("kind", "") != "tutorial":
					return false
				
				var completed_paths: Array = state.get("completed_tutorial_paths", [])
				var sequence_path: NodePath = \
					ancestor.get_path_to(self)
				
				if sequence_path in completed_paths:
					_restored_completed = true
					return true
				
				return false
		
		ancestor = ancestor.get_parent()
	
	return false
