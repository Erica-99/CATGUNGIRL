extends State
class_name GrappleShooting

var current_firing_curve: Curve

func enter() -> void:
	_setup_grapple()

func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func _setup_grapple() -> void:
	if not blackboard["grapple_raycast"].is_colliding():
		return
	
	blackboard["target_position"] = _get_grapple_point()
	blackboard["fired_position"] = blackboard["grapplegun_object"].position
	
	var grapple_scene_instance = blackboard["grapple_hook_scene"].instantiate()
	grapple_scene_instance.position = blackboard["fired_position"]
	grapple_scene_instance.rotation = blackboard["grapplegun_object"].rotation
	
	blackboard["current_grapple_hook"] = grapple_scene_instance
	
	get_tree().root.add_child(grapple_scene_instance)


func _get_grapple_point() -> Vector3:
	var point := Vector3.ZERO
	if blackboard["grapple_raycast"].is_colliding():
		point = blackboard["grapple_raycast"].get_collision_point()
		
	return point


func _rescale_curve_to_integral(curve: Curve, integral: float = 1) -> Curve:
	var scaled_curve: Curve = curve.duplicate()
	
	var curve_points: PackedVector2Array = []
	var step_width: float = 1 / (curve.bake_resolution - 1)
	
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
