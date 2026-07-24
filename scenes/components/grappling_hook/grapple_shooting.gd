extends State
class_name GrappleShooting

@export var gravity_multiplier: float = 1.0

var current_firing_curve: Curve
var do_fire_loop: bool = false
var time_elapsed: float = 0

var cancelled = false

func enter() -> void:
	_setup_grapple()
	time_elapsed = 0

func exit() -> void:
	do_fire_loop = false
	if cancelled:
		cancelled = false
		blackboard["grapplegun_object"].cancel_hook.emit()

func update(_delta: float) -> void:
	if cancelled or not blackboard["grapplegun_object"].active:
		cancelled = true
		transitioned.emit(self, "grappleretracted")
	
	pass

func physics_update(_delta: float) -> void:
	var actor = blackboard["actor"]
	#Gravity
	if not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * _delta * gravity_multiplier
	
	if not do_fire_loop:
		return
	
	var hook_object: Node3D = blackboard["current_grapple_hook"]
	var start_pos: Vector3 = blackboard["fired_position"]
	var end_pos: Vector3 = blackboard["target_position"]
	
	if hook_object.collided:
		transitioned.emit(self, "GrappleReeling")
		return
	elif time_elapsed >= 3:
		cancelled = true
		return
	
	var move_unit_vector = (end_pos - start_pos).normalized()
	move_unit_vector = move_unit_vector * (_delta / blackboard["total_fire_time"]) * current_firing_curve.sample(time_elapsed / blackboard["total_fire_time"])
	
	hook_object.global_position += move_unit_vector
	time_elapsed += _delta

func _setup_grapple() -> void:
	if not blackboard["grapple_raycast"].is_colliding():
		cancelled = true
		return
	
	blackboard["target_position"] = _get_grapple_point()
	blackboard["fired_position"] = blackboard["rope_attach_point"].global_position
	
	var grapple_scene_instance = blackboard["grapple_hook_scene"].instantiate()
	grapple_scene_instance.gun_anchor_object = blackboard["rope_attach_point"]
	grapple_scene_instance.position = blackboard["fired_position"]
	grapple_scene_instance.rotation = blackboard["grapplegun_object"].rotation
	
	blackboard["current_grapple_hook"] = grapple_scene_instance
	
	get_tree().root.add_child(grapple_scene_instance)
	
	var fire_dist = (blackboard["target_position"] - blackboard["fired_position"]).length()
	current_firing_curve = _rescale_curve_to_integral(blackboard["firing_curve"], fire_dist)
	
	do_fire_loop = true


func _get_grapple_point() -> Vector3:
	var point := Vector3.ZERO
	if blackboard["grapple_raycast"].is_colliding():
		point = blackboard["grapple_raycast"].get_collision_point()
		
	return point


func _rescale_curve_to_integral(curve: Curve, integral: float = 1) -> Curve:
	var scaled_curve: Curve = curve.duplicate()
	scaled_curve.max_value = 100
	
	var curve_points: PackedVector2Array = []
	var step_width: float = 1.0 / (curve.bake_resolution - 1)
	
	for i in range(curve.bake_resolution):
		var x: float = i * step_width
		var y: float = scaled_curve.sample(x)
		curve_points.append(Vector2(x, y))
	
	var total_area: float = 0
	for i in range(curve.bake_resolution - 1):
		var y1: float = curve_points[i].y
		var y2: float = curve_points[i+1].y
		total_area += ((y1 + y2) / 2) * step_width
	
	scaled_curve.clear_points()
	for point in curve_points:
		var new_point: Vector2 = Vector2(point.x, (point.y / total_area) * integral)
		scaled_curve.add_point(new_point)
	
	return scaled_curve
