extends Area3D

signal hurtbox_hit(hurtbox: Area3D)
signal damage_dealt(total_damage: float)

@export var team_component: Node
@export var damage_or_heal_instance: DamageHealInstance
@export var environment_check: RayCast3D
# WHERE OBSTRUCTED DAMAGE IS ZERO, NO DAMAGE IS DEALT
@export var obstructed_damage: float = 0.0

## Called by the hurtbox that this hitbox hits
func register_hit(hurtbox: Area3D) -> void:
	hurtbox_hit.emit(hurtbox)

func register_damage_dealt(damage: float) -> void:
	damage_dealt.emit(damage)

func handle_obstructed_hit(hurtbox: Area3D) -> float:
	# environment check intended to check and see if environment is in between hurtbox and hitbox
	# if environment is in the way, no damage is dealt (no hurtbox signal emitted)
	if environment_check != null:
		environment_check.target_position = environment_check.to_local(hurtbox.global_position)
		# enable for check
		environment_check.enabled = true
		environment_check.force_raycast_update()
		# if is colliding, then do not emit signal
		if environment_check.is_colliding():
			# disable collision checks
			environment_check.enabled = false
			return obstructed_damage
		# disable collision checks
		environment_check.enabled = false
	
	# negative means no obstruction
	return -1
