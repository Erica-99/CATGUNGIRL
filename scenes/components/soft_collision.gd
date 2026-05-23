# A repulsion force for enemy collisions so that they don't
# overlap completely with other enemies/the player

# Enemies and Player will have their own SoftCollider area.
# An enemy's soft collider will check for other soft colliders and
# push them back from it.
# The player's soft collider won't push them back, and is simply there
# to push back enemies standing on top of them.
extends Area3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

# Checks if Soft Collision Area is overlapping with other areas
func is_colliding():
	var areas = get_overlapping_areas()
	return areas.size() > 0

func get_push_vector():
	var areas = get_overlapping_areas()
	var push_vector = Vector3.ZERO
	if is_colliding():
		var area = areas[0]
		push_vector = area.global_position.direction_to(global_position)
	return push_vector
