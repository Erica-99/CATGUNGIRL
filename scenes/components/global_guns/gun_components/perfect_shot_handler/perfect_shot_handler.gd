extends Node3D

@onready var gun: BaseGun = $"../.."

@export_group("Perfect Shot")
@export var aim_settled_threshold: float = 98.0		# % of recoil recovered
@export var perfect_damage_multiplier: float = 1.5	# damage bonus for perfect shot
@export var perfect_shot_max_interval: float = 1.0	# max seconds between shots for perfect shot to trigger
@export var laser_convergence_speed: float = 0.73	# time to converge

#signal perfect_shot_fired()

func _shoot_handler():
	var damage = gun.bullet_damage
	## Perfect shot
	if gun._is_aim_settled() and gun._time_since_last_shot < perfect_shot_max_interval:
		gun._is_spamming = false
		gun._spam_count = 0
		print("Perfect Shot fired, damage: ", damage * perfect_damage_multiplier)
		rotation.z = gun._current_target_angle
		damage = damage * perfect_damage_multiplier
		#perfect_shot_fired.emit()
		AudioManager.play_sfx("laser_perfect")
		_perfect_flash.restart()
		Muzzle_VFX.stop()
		Muzzle_VFX.play("Perfect")
	# Spam shot 
	elif _time_since_last_shot < spam_window:
		_is_spamming = true
		_spam_count += 1
		# print("spam shot, count: ", _spam_count)
		AudioManager.play_sfx("laser_imperfect")
		_normal_flash.restart()
		Muzzle_VFX.stop()
		Muzzle_VFX.play("Imperfect")
	else: # Normal shot
		# print("normal shot, damage: ", bullet_damage)
		AudioManager.play_sfx("laser_imperfect")
		_normal_flash.restart()
		Muzzle_VFX.stop()
		Muzzle_VFX.play("Imperfect")
	# resets firing cooldown
	_fire_cooldown = fire_rate
	_shoot(damage, bullet_scale)
	_recoil_offset += recoil_amount * sign(global_transform.basis.x.x)
	_time_since_last_shot = 0.0
	single_reload_timer = 0.0
	# _has_printed_settle = false
