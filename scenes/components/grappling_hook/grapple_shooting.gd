extends State
class_name GrappleShooting

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
