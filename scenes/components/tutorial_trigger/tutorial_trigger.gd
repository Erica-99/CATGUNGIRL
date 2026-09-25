extends Node

signal finished

@export var sequence_name: String

@export var steps: Array[TutorialStep] = []
@export var autostart: bool = true

## OPTIONAL: Choose which door to unlock when tutorial steps are completed
@export var door_to_unlock: Node3D

func _ready() -> void:
	EventManager.initiate_tutorial_sequence.connect(_on_tutorial_sequence_triggered)
	if autostart:
		start()

func _on_tutorial_sequence_triggered(requested_sequence_name: String) -> void:
	if requested_sequence_name == sequence_name:
		start()

func start() -> void:
	TutorialManager.sequence_finished.connect(_on_sequence_finished, CONNECT_ONE_SHOT)
	TutorialManager.start(steps)

func _on_sequence_finished() -> void:
	finished.emit()
	if door_to_unlock:
		EventManager.set_door_openable_state.emit(door_to_unlock, true)
