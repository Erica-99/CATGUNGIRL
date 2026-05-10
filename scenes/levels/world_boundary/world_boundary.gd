extends StaticBody3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@export var room_ID: Enums.Room

func _ready() -> void:
	EventManager.room_cleared.connect(_check_door_status)

func _check_door_status(cleared_room_ID: Enums.Room) -> void:
	print("CLEARED ROOM ID: " + str(cleared_room_ID) + ", OG ROOM ID: " + str(room_ID))
	if cleared_room_ID == room_ID:
		collision_shape_3d.disabled = true
