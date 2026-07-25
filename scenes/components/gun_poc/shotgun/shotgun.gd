extends Gun

@export_category("Gun Specific Stats")
@export var pellet_amount: int = 10

func _shoot(damage, bullet_scale):
	for i in pellet_amount:
		_spawn_bullet(damage, bullet_scale)


func _on_airblast_component_enemy_hit(damage: float) -> void:
	enemy_hit.emit(damage)
