extends Node3D

@export var grapple_raycast: RayCast3D

var fired_position: Vector3
var target_position: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _fire_grapple() -> void:
	if not grapple_raycast.is_colliding():
		return
	
	target_position = _get_grapple_point()
	fired_position = position
	
	# Need code to initiate coroutine to lerp the grapple. Or trigger a routine in _physics_process.
	pass


func _get_grapple_point() -> Vector3:
	var point := Vector3.ZERO
	if grapple_raycast.is_colliding():
		point = grapple_raycast.get_collision_point()
		
	return point
