extends Area3D

signal hurtbox_hit(hurtbox: Area3D)
signal damage_dealt(total_damage: float)

@export var team_component: Node
@export var damage_or_heal_instance: DamageHealInstance

## Called by the hurtbox that this hitbox hits
func register_hit(hurtbox: Area3D) -> void:
	hurtbox_hit.emit(hurtbox)

func register_damage_dealt(damage: float) -> void:
	damage_dealt.emit(damage)
