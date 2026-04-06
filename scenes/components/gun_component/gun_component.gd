extends Node3D

## gun component - handles aiming, normal fire, and charged shots
## attach as a child of player node

## exported variables
@export var bullet_scene: PackedScene	# bullet.tscn file to spawn when firing
@export var muzzle: Marker3D			# bullet spawn at muzzle tip
@export var sprite: AnimatedSprite3D	# player sprite reference, for flipping left/right
@export var team_component: Node		# player TeamComponent reference, passed to bullets
@export var input_component: Node

@export_group("Aim")
@export var aim_speed: float = 8.0		# gun rotation speed towards mouse (lower = more delay)
@export var aim_angle_min: float = -80.0	# max upward aiming angle in degrees (negative = up)
@export var aim_angle_max: float = 80.0		# max downward aiming angle in degrees

@export_group("Normal Fire")
@export var fire_rate: float = 0.15		# min time (seconds) between shots
@export var bullet_damage: float = 10.0		# bullet damage
@export var bullet_knockback: float = 5.0	# knockback force (can remove)
@export var bullet_scale: float = 1.0	# visual size of bullet 

@export_group("Charged Shot")
@export var charge_mode: Enums.ChargeMode = Enums.ChargeMode.AUTO_FIRE	# which charge mode is active (switch in inspector)

## AUTO_FIRE
@export var auto_charge_duration: float = 0.5 # time (seconds) before auto fire from right click

## HOLD_TO_FIRE
@export var hold_charge_min: float = 0.2	# time (seconds) to hold for charged shot otherwise it cancels
@export var hold_charge_max: float = 2.0	# time (seconds) to reach max charge, longer hold does nothing

## min charge
@export var charged_damage_min: float = 20.0 		# damage at min charge
@export var charged_bullet_scale_min: float = 1.5	# size at min charge

## max charge
@export var charged_damage_max: float = 60.0		# damage at max charge
@export var charged_bullet_scale_max: float = 3.0	# size at max charge

## signal is emitted every frame while charging, value is 0.0 to 1.0
## connects to charge bar UI element.
signal charge_progress_changed(progress: float)

## Signal emitted when charging stops (fired or cancelled)
signal charge_ended()
signal enemy_hit(hurtbox: Area3D)

var _current_angle: float = 0.0		# gun current rotation angle
var _facing_right: bool = true		# tracks which direction player is facing)
var _fire_cooldown: float = 0.0		# gunshot cooldown (timer in seconds)

# charge state
var _is_charging: bool = false	# is a charged shot being charged?
var _charge_timer: float = 0.0	# how long (seconds) player has been charging


func _process(delta: float) -> void:
	var current_input_state = input_component.get_input_state()
	
	_update_aim(current_input_state.get("mouse_world_pos"), delta)			# updates gun rotation to follow mouse
	_fire_cooldown = maxf(_fire_cooldown - delta, 0.0) # keeps fire cooldown above 0

	# normal fire - left click
	var fire_held = current_input_state.get("fire_held", false)

	if fire_held:
		_try_fire()

	# charged shot input handling
	_handle_charge_input(current_input_state, delta)


func _update_aim(mouse_world: Vector3, delta: float) -> void:
	if mouse_world == null:
		return

	var direction = mouse_world - global_position
	direction.z = 0.0

	_facing_right = direction.x >= 0.0	# mouse on right of player = facing right

	if sprite != null:					# flip sprite when facing left
		sprite.flip_h = !_facing_right

	var abs_direction = Vector2(abs(direction.x), direction.y)
	var target_angle = abs_direction.angle()
	
	# clamp restricts angle within min/max range
	target_angle = clamp(
		target_angle,
		deg_to_rad(aim_angle_min),
		deg_to_rad(aim_angle_max)
	)
	
	## lerp_angle moves _current_angle towards target_angle each frame
	# aim_speed * delta: controls speed, creates delay
	_current_angle = lerp_angle(_current_angle, target_angle, aim_speed * delta)

	if _facing_right:
		rotation.z = _current_angle
	else:
		rotation.z = PI - _current_angle	# angle mirrors when facing left

	scale = Vector3(1.0, 1.0, 1.0)


func _handle_charge_input(input_state, delta: float) -> void:
	var charge_fire_held = input_state.get("charge_fire_held", false)
	
	if charge_mode == Enums.ChargeMode.AUTO_FIRE:
		# right click pressed -> begin charge, ignore if already charging
		if charge_fire_held and not _is_charging:
			_is_charging = true
			_charge_timer = 0.0

		if _is_charging:
			_charge_timer += delta
			var progress = clampf(_charge_timer / auto_charge_duration, 0.0, 1.0)
			charge_progress_changed.emit(progress)

			# auto fire once fully charged
			if _charge_timer >= auto_charge_duration:
				_fire_charged(1.0)

	elif charge_mode == Enums.ChargeMode.HOLD_TO_FIRE:
		# begin charging while held (RMB)
		if charge_fire_held:
			if not _is_charging:
				_is_charging = true
				_charge_timer = 0.0
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
				# calcs charge progress and fires
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
		
	# resets firing cooldown
	_fire_cooldown = fire_rate
	_spawn_bullet(bullet_damage, bullet_scale)


func _fire_charged(progress: float) -> void:
	# reset charge state
	_is_charging = false
	_charge_timer = 0.0
	print("firing charge_ended signal")
	# tell chargebar ui charging ended
	charge_ended.emit()

	if bullet_scene == null or muzzle == null:
		return

	# lerp damage and size based on charge progress
	var damage = lerpf(charged_damage_min, charged_damage_max, progress)
	var size = lerpf(charged_bullet_scale_min, charged_bullet_scale_max, progress)
	_spawn_bullet(damage, size)


func _spawn_bullet(damage: float, size: float) -> void:
	var bullet = bullet_scene.instantiate()	# new instance of bullet 
	get_tree().root.add_child(bullet)	# adds to root of scene so not parented to gun
	bullet.global_transform = muzzle.global_transform	# bullet is placed at muzzle position

	## builds direction vector for bullet trajectory
	# cos/sin converts angle to X/Y components
	# if facing left, X is negated to flip direction
	var aim_dir: Vector3
	if _facing_right:
		aim_dir = Vector3(cos(_current_angle), sin(_current_angle), 0.0).normalized()
	else:
		aim_dir = Vector3(-cos(_current_angle), sin(_current_angle), 0.0).normalized()

	## creates new DamageHealInstance for bullet damage data
	# each bullet gets its own instance so no sharing/overwriting other bullet data
	var damage_instance = DamageHealInstance.new()
	damage_instance.amount = damage
	damage_instance.is_heal = false					# false = damage, not healing
	damage_instance.type = Enums.DamageType.NORMAL
	damage_instance.knockback = bullet_knockback
	damage_instance.source = get_path()

	bullet.initialize(aim_dir, damage_instance, team_component, size)
	var hb = bullet.get_node("HitboxComponent") 
	hb.hurtbox_hit.connect(func(hurtbox): enemy_hit.emit(hurtbox))
