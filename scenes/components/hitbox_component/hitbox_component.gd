extends Area3D

signal hurtbox_hit(hurtbox: Area3D)

@export var team_component: Node
@export var damage_or_heal_instance: DamageHealInstance


## Called by the hurtbox that this hitbox hits
func register_hit(hurtbox: Area3D) -> void:
	hurtbox_hit.emit(hurtbox)
