extends StaticBody3D

@export var door_to_unlock: Node3D
@export var unlock_door_on_pickup: bool = true

@export var interactable_component: Node3D

@export var tutorial_step_name_to_enable_on: String = "Interacting"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.tutorial_step_started.connect(_enable_on_interact_tutorial_started)
	if unlock_door_on_pickup:
		EventManager.gun_picked_up.connect(unlock_door)

func unlock_door():
	EventManager.set_door_openable_state.emit(door_to_unlock, true)

func _enable_on_interact_tutorial_started(tutorial_name: String) -> void:
	if tutorial_name == tutorial_step_name_to_enable_on:
		interactable_component.enabled = true
		EventManager.tutorial_step_started.disconnect(_enable_on_interact_tutorial_started)
