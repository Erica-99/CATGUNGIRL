extends StaticBody3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

# TEMP VAR REMOVE WHEN ENEMIES IN GAME
var flip_bool: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.enemies_active.connect(_check_door_status)
	pass # Replace with function body.

func _check_door_status(enemies_active: bool) -> void:
	collision_shape_3d.disabled = !enemies_active

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		flip_bool = !flip_bool
		EventManager.enemies_active.emit(flip_bool)
