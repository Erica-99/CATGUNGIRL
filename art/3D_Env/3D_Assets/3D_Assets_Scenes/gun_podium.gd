extends StaticBody3D

@export var door_to_unlock: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.gun_picked_up.connect(_unlock_door)

func _unlock_door():
	EventManager.set_door_openable_state.emit(door_to_unlock, true)
