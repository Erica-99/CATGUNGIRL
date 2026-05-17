extends Node3D

## gun component - handles aiming, normal fire, and charged shots
## attach as a child of player node

## exported variables
@export var bullet_scene: PackedScene	# bullet.tscn file to spawn when firing
@export var muzzle: Marker3D			# bullet spawn at muzzle tip
@export var team_component: Node		# player TeamComponent reference, passed to bullets
@export var input_component: Node

@export_group("Aim")
@export var aim_speed: float = 8.0		# gun rotation speed towards mouse (lower = more delay)

@export_group("Normal Fire")
@export var fire_rate: float = 0.15			# min time (seconds) between shots
@export var bullet_damage: float = 10.0
@export var bullet_knockback: float = 5.0	# knockback force (can remove)
@export var bullet_scale: float = 1.0
@export var recoil_amount: float = 0.35		# higher = more
@export var recoil_recovery: float = 5.0 	# higher = faster
@export var wobble_amount: float = 0.1		# higher = more
@export var wobble_speed: float = 7.0		# higher = faster

@export_group("Spam Fire")
@export var spam_spread_angle: float = 5.0			# max degrees of random offset per spam shot
@export var spam_spread_increase: float = 2.0		# extra degrees added per consecutive spam shot
@export var spam_max_spread: float = 15.0			# max spread angle
@export var spam_aim_multiplier: float = 0.4		# lower = slower
@export var spam_window: float = 0.6				# seconds after firing where next shot counts as spam


@export_group("Perfect Shot")
@export var aim_settled_threshold: float = 98.0		# % of recoil recovered
@export var perfect_damage_multiplier: float = 1.5	# damage bonus for perfect shot
@export var perfect_shot_max_interval: float = 1.0	# max seconds between shots for perfect shot to trigger
@export var laser_convergence_speed: float = 0.73	# time to converge

@export_group("Charged Shot")
@export var charge_mode: Enums.ChargeMode = Enums.ChargeMode.AUTO_FIRE	# which charge mode is active (switch in inspector)

## AUTO_FIRE
@export var auto_charge_duration: float = 0.5 # time (seconds) before auto fire from right click

## HOLD_TO_FIRE
@export var hold_charge_min: float = 0.2	# time (seconds) to hold for charged shot otherwise it cancels
@export var hold_charge_max: float = 2.0	# time (seconds) to reach max charge, longer hold does nothing

## charged bullet stats at min and max charge
@export var charged_damage_min: float = 20.0
@export var charged_damage_max: float = 60.0
@export var charged_bullet_scale_min: float = 1.5
@export var charged_bullet_scale_max: float = 3.0
@export var charged_recoil_multiplier: float = 2.0  # higher recoil for charged shot

## emitted every frame while charging, value is 0.0 to 1.0
signal charge_progress_changed(progress: float)

## Signal emitted when charging stops (fired or cancelled)
signal charge_ended()
signal charge_started()
signal enemy_hit(hurtbox: Area3D)

## perfect shot signal, connect later for visual indicator
signal perfect_shot_fired()
signal spread_changed(spread: float) # visual indicator 

var _fire_cooldown: float = 0.0
var _recoil_offset: float = 0.0 
var _is_charging: bool = false
var _charge_timer: float = 0.0		# how long (seconds) player has been charging
var _wobble_time: float = 0.0
var _current_target_angle: float = 0.0	# stores current target angle for perfect shot detection
var _time_since_last_shot: float = 999.0
var _is_spamming: bool = false
var _spam_count: int = 0			# track spam count
# var _has_printed_settle: bool = false

# check if aim within threshold
func _is_aim_settled() -> bool:
	return abs(_recoil_offset) < recoil_amount * (1.0 - aim_settled_threshold / 100.0)

func _process(delta: float) -> void:
	var current_input_state = input_component.get_input_state()
	_update_aim(current_input_state.get("mouse_world_pos"), current_input_state, delta)
	_fire_cooldown = maxf(_fire_cooldown - delta, 0.0)
	_time_since_last_shot += delta
	if _time_since_last_shot >= spam_window:
		_is_spamming = false
		_spam_count = 0
	# normal fire (left click) read from input component
	if current_input_state.get("fire_held", false):
		_try_fire()
	# charged shot input handling
	_handle_charge_input(current_input_state, delta)
	var spread = 1.0 - clampf(_time_since_last_shot / laser_convergence_speed, 0.0, 1.0)
	spread_changed.emit(spread)


func _update_aim(mouse_world: Vector3, input_state: Dictionary, delta: float) -> void:
	if mouse_world == null:
		return
	# direction vector from gun to mouse
	var direction = mouse_world - global_position
	direction.z = 0.0
	var target_angle = Vector2(direction.x, direction.y).angle()
	_current_target_angle = target_angle
	
	var is_moving = input_state.get("movement", 0.0) != 0.0 or input_state.get("jumping", false)
	var wobble: float = 0.0
	if is_moving:
		_wobble_time += delta
		wobble = sin(_wobble_time * wobble_speed) * wobble_amount
	else:
		_wobble_time = 0.0
		
	var current_aim_speed = aim_speed
	if _is_spamming and not _is_aim_settled():
		current_aim_speed = aim_speed * spam_aim_multiplier
		
	rotation.z = lerp_angle(rotation.z, target_angle + _recoil_offset + wobble, current_aim_speed * delta)
	_recoil_offset = lerpf(_recoil_offset, 0.0, recoil_recovery * delta)
	if abs(_recoil_offset) < 0.001:
		_recoil_offset = 0.0
	scale = Vector3(1.0, 1.0, 1.0)
	## print to check recoil recovery
	# if _is_aim_settled() and _time_since_last_shot < perfect_shot_max_interval:
		# if not _has_printed_settle:
			# print("aim settled: ", _time_since_last_shot, " seconds after last shot")
			# _has_printed_settle = true

func _handle_charge_input(input_state: Dictionary, delta: float) -> void:
	var charge_fire_held = input_state.get("charge_fire_held", false)
	
	if charge_mode == Enums.ChargeMode.AUTO_FIRE:
		# right click pressed -> begin charge, ignore if already charging
		if charge_fire_held and not _is_charging:
			_is_charging = true
			_charge_timer = 0.0
			charge_started.emit()
		if _is_charging:
			_charge_timer += delta
			var progress = clampf(_charge_timer / auto_charge_duration, 0.0, 1.0)
			charge_progress_changed.emit(progress)
			# auto fire once fully charged
			if _charge_timer >= auto_charge_duration:
				_fire_charged(1.0)
	
	elif charge_mode == Enums.ChargeMode.HOLD_TO_FIRE:
		if charge_fire_held:
			if not _is_charging:
				_is_charging = true
				_charge_timer = 0.0
				charge_started.emit()
			_charge_timer += delta
			var progress = clampf(
				# charge progress starts at 0 ONLY after min hold time
				(_charge_timer - hold_charge_min) / (hold_charge_max - hold_charge_min),
				0.0, 1.0
			)
			charge_progress_changed.emit(progress)
			# caps charge timer so it doesn't go past max
			_charge_timer = minf(_charge_timer, hold_charge_max)
			
		# release -> fire if charged enough, otherwise cancel
		if not charge_fire_held and _is_charging:
			if _charge_timer >= hold_charge_min:
				var progress = clampf(
					(_charge_timer - hold_charge_min) / (hold_charge_max - hold_charge_min),
					0.0, 1.0
				)
				_fire_charged(progress)
			else:
				# released too early, cancel
				_is_charging = false
				_charge_timer = 0.0
				charge_ended.emit()


func _try_fire() -> void:
	# won't fire if cooldown not expired
	if _fire_cooldown > 0.0:
		return
	if bullet_scene == null or muzzle == null:
		return
	var damage = bullet_damage
	
	## Perfect shot
	if _is_aim_settled() and _time_since_last_shot < perfect_shot_max_interval:
		_is_spamming = false
		_spam_count = 0
		print("Perfect Shot fired, damage: ", bullet_damage * perfect_damage_multiplier)
		rotation.z = _current_target_angle
		damage = bullet_damage * perfect_damage_multiplier
		perfect_shot_fired.emit()
		AudioManager.play_sfx("laser_perfect")
	# Spam shot 
	elif _time_since_last_shot < spam_window:
		_is_spamming = true
		_spam_count += 1
		# print("spam shot, count: ", _spam_count)
		AudioManager.play_sfx("laser_imperfect")
	else: # Normal shot
		# print("normal shot, damage: ", bullet_damage)
		AudioManager.play_sfx("laser_imperfect")
		
	# resets firing cooldown
	_fire_cooldown = fire_rate
	_spawn_bullet(damage, bullet_scale)
	_recoil_offset += recoil_amount * sign(global_transform.basis.x.x)
	_time_since_last_shot = 0.0
	# _has_printed_settle = false


func _fire_charged(progress: float) -> void:
	# reset charge state
	_is_charging = false
	_charge_timer = 0.0
	# tell chargebar ui charging ended
	charge_ended.emit()
	if bullet_scene == null or muzzle == null:
		return
	# lerp damage and size based on charge progress
	var damage = lerpf(charged_damage_min, charged_damage_max, progress)
	var size = lerpf(charged_bullet_scale_min, charged_bullet_scale_max, progress)
	_spawn_bullet(damage, size)
	_recoil_offset += recoil_amount * charged_recoil_multiplier * progress * sign(global_transform.basis.x.x)


func _spawn_bullet(damage: float, size: float) -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	
	var aim_dir = Vector3(cos(rotation.z), sin(rotation.z), 0.0).normalized()
	
	# new spread
	if _is_spamming:
		var total_spread = deg_to_rad(minf(spam_spread_angle + spam_spread_increase * (_spam_count - 1), spam_max_spread))
		var random_offset = randf_range(-total_spread, total_spread)
		aim_dir = aim_dir.rotated(Vector3(0.0, 0.0, 1.0), random_offset)
	
	var damage_instance = DamageHealInstance.new()
	damage_instance.amount = damage
	damage_instance.is_heal = false
	damage_instance.type = Enums.DamageType.NORMAL
	damage_instance.knockback = bullet_knockback
	damage_instance.source = get_path()
	
	bullet.initialize(aim_dir, damage_instance, team_component, size)
	var hb = bullet.get_node("HitboxComponent") 
	hb.hurtbox_hit.connect(func(hurtbox): enemy_hit.emit(hurtbox))
	
