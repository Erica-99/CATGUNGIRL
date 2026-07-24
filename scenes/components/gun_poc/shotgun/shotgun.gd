extends Gun

func _shoot(damage, bullet_scale):
	for i in 10:
		_spawn_bullet(damage, bullet_scale)
