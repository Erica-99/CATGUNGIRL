extends Gun

func _shoot(damage, bullet_scale):
	AudioManager.play_sfx("laser_imperfect")
	_spawn_bullet(damage, bullet_scale)
