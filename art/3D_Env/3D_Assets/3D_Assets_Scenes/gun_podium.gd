extends StaticBody3D

@export var door_to_unlock: Node3D
@export var unlock_door_on_pickup: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if unlock_door_on_pickup:
		EventManager.gun_picked_up.connect(unlock_door)

func unlock_door():
	EventManager.set_door_openable_state.emit(door_to_unlock, true)
