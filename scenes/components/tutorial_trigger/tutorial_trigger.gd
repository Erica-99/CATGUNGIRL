extends Node

signal finished

@export var steps: Array[TutorialStep] = []
@export var autostart: bool = true

## OPTIONAL: Choose which door to unlock when tutorial steps are completed
@export var door_to_unlock: Node3D

func _ready() -> void:
	if autostart:
		start()

func start() -> void:
	TutorialManager.sequence_finished.connect(_on_sequence_finished, CONNECT_ONE_SHOT)
	TutorialManager.start(steps)

func _on_sequence_finished() -> void:
	finished.emit()
	if door_to_unlock:
		EventManager.set_door_openable_state.emit(door_to_unlock, true)
