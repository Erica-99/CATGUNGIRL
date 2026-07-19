extends Gun

func _shoot(damage, bullet_scale):
	for i in 8:
		_spawn_bullet(damage, bullet_scale)
