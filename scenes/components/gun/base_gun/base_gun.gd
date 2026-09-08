extends Node3D

class_name BaseGun

# base gun is designed to hold the absolute basics
# most functionality is completed via the attached additional nodes
# however, gun instances such as Pistol, Shotgun etc. shall inherit fom base gun to obtain the basics (then have customised attached nodes)
# some attached nodes will be forced (such as the BulletEmitter), others will be optional (i.e. attached handling for Player aiming etc idk)

@onready var ammo_component: AmmoComponent = $AmmoComponent
@onready var bullet_emitter: Node3D = $BulletEmitter
var input_component: Node

@export var team_component: Node = null		# player or enemy TeamComponent reference, passed to bullets
@export var gun_animator: AnimationPlayer = null
@export var muzzle_vfx: AnimationPlayer = null
@export var _normal_flash: CPUParticles3D
@export var _perfect_flash: CPUParticles3D

@export var ability: Ability = null

@export_group("Aim")
@export var aim_speed: float = 8.0		# gun rotation speed towards mouse (lower = more delay)
@export var controller_aim_speed = 3.5

@export_group("Perfect Shot")
@export var aim_settled_threshold: float = 98.0		# % of recoil recovered
@export var perfect_damage_multiplier: float = 1.5	# damage bonus for perfect shot
@export var perfect_shot_max_interval: float = 1.0	# max seconds between shots for perfect shot to trigger
@export var laser_convergence_speed: float = 0.73	# time to converge
@export var spam_window: float = 0.6				# seconds after firing where next shot counts as spam
@export var spam_aim_multiplier: float = 0.4		# lower = slower

@export_group("Recoil and Wobble")
@export var recoil_amount: float = 0.35		# higher = more
@export var recoil_recovery: float = 5.0 	# higher = faster
@export var wobble_amount: float = 0.1		# higher = more
@export var wobble_speed: float = 7.0		# higher = faster

@export_group("ENEMY Barrage")
@export var bullets_per_barrage: int = 3

var _is_spamming: bool = false
var _spam_count: int = 0			# track spam count
var _recoil_offset: float = 0.0 
var _current_target_angle: float = 0.0	# stores current target angle for perfect shot detection
var _time_since_last_shot: float = 999.0
var _fire_cooldown: float = 0.0
var _is_charging: bool = false
var _charge_progress: float = 0.0	# beam
var _wobble_time: float = 0.0

var _enemy_bullets_fired: int = 0

## Controller Aiming variables
var using_controller = false
var controller_deadzone = 0.2
var target_angle : float

var active: bool = false:
	set(value):
		active = value
		visible = active
		if ability != null:
			ability.active = active

signal enemy_hit(damage: float)

## perfect shot signal
signal perfect_shot_fired()
signal spread_changed(spread: float) # visual indicator 
signal perfect_window_changed(active: bool) # for indicator flash


func _input(event):
	#Establish if the player is using KBM or a controller
	if event is InputEventJoypadMotion:
		if abs(event.axis_value) > controller_deadzone:
			using_controller = true
	elif event is InputEventMouseMotion:
			using_controller = false

func _process(delta: float) -> void:
	# in hindsight, the is_reloading should probably have a set of interactions for attempted bulletshots whilst reload but anyways...
	if !active:
		return
	
	# HANDLE PLAYER
	if team_component.team == Enums.Team.PLAYER:
		var current_input_state = input_component.get_input_state()
		_update_aim(current_input_state.get("mouse_world_pos"), current_input_state, delta)
		_fire_cooldown = maxf(_fire_cooldown - delta, 0.0)
		_time_since_last_shot += delta
		if _time_since_last_shot >= spam_window:
			_is_spamming = false
			_spam_count = 0
		
		if !ammo_component.is_reloading:
			# normal fire (left click) read from input component
			if current_input_state.get("fire_held", false):
				if bullet_emitter.full_auto:
					bullet_emitter._try_fire()
				else: # buffer the checks for semi-auto firing
					if bullet_emitter.semi_available:
						bullet_emitter._try_fire()
						
			# input handling for special attack
			_handle_special(current_input_state, delta)
		
		# buffer for semi auto firing
		if !bullet_emitter.full_auto:
			if input_component._fire_held:
				bullet_emitter.semi_available = false
			else:
				bullet_emitter.semi_available = true
			
		if _is_charging:
			spread_changed.emit(_charge_progress)
		else:
			var spread = 1.0 - clampf(_time_since_last_shot / laser_convergence_speed, 0.0, 1.0)
			spread_changed.emit(spread)
		var in_window = not _is_charging and _is_aim_settled() and _time_since_last_shot < perfect_shot_max_interval
		perfect_window_changed.emit(in_window)
	
	else:
		# HANDLE NON-PLAYER
		
		if ammo_component._check_if_can_shoot():
			_fire_cooldown += delta
			if _fire_cooldown > bullet_emitter.fire_rate:
				_fire_cooldown = 0
				bullet_emitter._spawn_bullet(bullet_emitter.bullet_damage, bullet_emitter.bullet_scale)


func _update_aim(mouse_world: Vector3, input_state: Dictionary, delta: float) -> void:
	if mouse_world == null:
		return
	#Check if the player is using a controller
	if using_controller:
		var controller_input = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		if controller_input.length() > controller_deadzone:
			controller_input.y *= -1
			target_angle = controller_input.angle()
			_current_target_angle = target_angle
	else:
		# direction vector from gun to mouse
		var direction = mouse_world - global_position
		direction.z = 0.0
		target_angle = Vector2(direction.x, direction.y).angle()
		_current_target_angle = target_angle
	
	var is_moving = input_state.get("movement", 0.0) != 0.0 or input_state.get("jumping", false)
	var wobble: float = 0.0
	if is_moving:
		_wobble_time += delta
		wobble = sin(_wobble_time * wobble_speed) * wobble_amount
	else:
		_wobble_time = 0.0
	
	#Set the current aim speed depending on user's input
	var current_aim_speed
	if using_controller:
		current_aim_speed = controller_aim_speed
	else:
		current_aim_speed = aim_speed
	
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


func _handle_special(input_state: Dictionary, delta: float) -> void:
	# overrided by instances of gun
	pass


func _is_aim_settled() -> bool:
	return abs(_recoil_offset) < recoil_amount * (1.0 - aim_settled_threshold / 100.0)

# player only aim handling
func _shoot_handler():
	var damage = bullet_emitter.bullet_damage
	## Perfect shot
	if _is_aim_settled() and _time_since_last_shot < perfect_shot_max_interval:
		_is_spamming = false
		_spam_count = 0
		print("Perfect Shot fired, damage: ", bullet_emitter.bullet_damage * perfect_damage_multiplier)
		rotation.z = _current_target_angle
		damage = bullet_emitter.bullet_damage * perfect_damage_multiplier
		perfect_shot_fired.emit()
		AudioManager.play_sfx("laser_perfect")
		_perfect_flash.restart()
		muzzle_vfx.stop()
		muzzle_vfx.play("Perfect")
	# Spam shot 
	elif _time_since_last_shot < spam_window:
		_is_spamming = true
		_spam_count += 1
		# print("spam shot, count: ", _spam_count)
		AudioManager.play_sfx("laser_imperfect")
		_normal_flash.restart()
		muzzle_vfx.stop()
		muzzle_vfx.play("Imperfect")
	else: # Normal shot
		# print("normal shot, damage: ", bullet_damage)
		AudioManager.play_sfx("laser_imperfect")
		_normal_flash.restart()
		muzzle_vfx.stop()
		muzzle_vfx.play("Imperfect")
	# resets firing cooldown
	_fire_cooldown = bullet_emitter.fire_rate
	bullet_emitter._shoot(damage, bullet_emitter.bullet_scale)
	_recoil_offset += recoil_amount * sign(global_transform.basis.x.x)
	_time_since_last_shot = 0.0
	ammo_component.single_reload_timer = 0.0
	# _has_printed_settle = false
