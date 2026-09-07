extends Gun

func _shoot(damage, bullet_scale):
	_spawn_bullet(damage, bullet_scale * 1.5)

func _on_beam_component_enemy_hit(damage: float) -> void:
	enemy_hit.emit(damage)
