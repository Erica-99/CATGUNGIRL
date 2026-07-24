extends Node3D

class_name Gun

const HITBOX_SCENE = preload("res://scenes/components/hitbox_component/hitbox_component.tscn")
## gun component - handles aiming, normal fire, and charged shots
## attach as a child of player node

## exported variables
@export var bullet_scene: PackedScene	# bullet.tscn file to spawn when firing
@export var team_component: Node		# player TeamComponent reference, passed to bullets
@export var ability: Ability

@export_group("Aim")
@export var aim_speed: float = 8.0		# gun rotation speed towards mouse (lower = more delay)

@export_group("Ammo")
@export var ammo_max: int = 10
@export var reload_time: float = 3.0
@export var reload_full: bool = true 	# differentiates full mag reloaders (pistol)
										# and single shot reloaders (shotgun)
var single_reload_timer: float = 0 # to control changing reload times (e.g. 1.0 -> 0.5 -> 0.5 -> 0.5)

@export_group("Normal Fire")
@export var fire_rate: float = 0.15			# min time (seconds) between shots
@export var full_auto: bool = true
@export var bullet_damage: float = 10.0
@export var bullet_knockback: float = 5.0	# knockback force (can remove)
@export var bullet_scale: float = 1.0
@export var bullet_velocity_multiplier: float = 1.0 # higher = faster
@export var recoil_amount: float = 0.35		# higher = more
@export var recoil_recovery: float = 5.0 	# higher = faster
@export var wobble_amount: float = 0.1		# higher = more
@export var wobble_speed: float = 7.0		# higher = faster
@export var base_aim_spread: float = 0		# for weapons with imperfect aiming

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

##Gun Animation Handler
@onready var muzzle: Marker3D = $Muzzle

## Reload timer (can be replaced with programmatical timer as needed)
@onready var reload_timer: Timer = $ReloadTimer

## bzzt

signal beam_fired(beam_end: Vector3, charge_progress: float)

## emitted every frame while charging, value is 0.0 to 1.0
signal charge_progress_changed(progress: float)

## Signal emitted when charging stops (fired or cancelled)
signal charge_ended()
signal charge_started()
signal enemy_hit(hurtbox: Area3D)

## perfect shot signal
signal perfect_shot_fired()
signal spread_changed(spread: float) # visual indicator 
signal perfect_window_changed(active: bool) # for indicator flash

@onready var _normal_flash: CPUParticles3D = $Muzzle/NormalMuzzleFlash
@onready var _perfect_flash: CPUParticles3D = $Muzzle/PerfectMuzzleFlash

## semi-auto buffer
var semi_available: bool = true

var Gun_Animation: AnimationPlayer
var Muzzle_VFX: AnimationPlayer

var input_component: Node

var active: bool = false:
	set(value):
		active = value
		visible = active
		if ability != null:
			ability.active = active

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
var _charge_progress: float = 0.0	# beam
var _is_perfect_charge: bool = false
@onready var _current_ammo: int = ammo_max
var _is_reloading: bool = false

# check if aim within threshold
func _is_aim_settled() -> bool:
	return abs(_recoil_offset) < recoil_amount * (1.0 - aim_settled_threshold / 100.0)

func _process(delta: float) -> void:
	
	# single shot reloading
	if !reload_full:
		if _current_ammo != ammo_max:
			single_reload_timer += delta
			if single_reload_timer > reload_time:
				_current_ammo += 1
				single_reload_timer = reload_time / 2.0
				if active: EventManager.shots_loaded.emit(1)
	
	# in hindsight, the is_reloading should probably have a set of interactions for attempted bulletshots whilst reload but anyways...
	if !active:
		return
	
	var current_input_state = input_component.get_input_state()
	_update_aim(current_input_state.get("mouse_world_pos"), current_input_state, delta)
	_fire_cooldown = maxf(_fire_cooldown - delta, 0.0)
	_time_since_last_shot += delta
	if _time_since_last_shot >= spam_window:
		_is_spamming = false
		_spam_count = 0
	
	if !_is_reloading:
		# normal fire (left click) read from input component
		if current_input_state.get("fire_held", false):
			if full_auto:
				_try_fire()
			else: # buffer the checks for semi-auto firing
				if semi_available:
					_try_fire()
					
		# input handling for special attack
		_handle_special(current_input_state, delta)
	
	# buffer for semi auto firing
	if !full_auto:
		if input_component._fire_held:
			semi_available = false
		else:
			semi_available = true
		
	if _is_charging:
		spread_changed.emit(_charge_progress)
	else:
		var spread = 1.0 - clampf(_time_since_last_shot / laser_convergence_speed, 0.0, 1.0)
		spread_changed.emit(spread)
	var in_window = not _is_charging and _is_aim_settled() and _time_since_last_shot < perfect_shot_max_interval
	perfect_window_changed.emit(in_window)


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

func _handle_special(input_state: Dictionary, delta: float) -> void:
	# overrided by instances of gun
	pass

func _try_fire() -> void:
	# won't fire on empty ammo (added for shotgun)
	if _current_ammo == 0:
		return
	# won't fire if cooldown not expired
	if _fire_cooldown > 0.0:
		return
	if bullet_scene == null or muzzle == null:
		print("Bullet scene or muzzle is currently null. Cannot fire.")
		return
	
	#Play Gun Animation
	_play_shoot_animation()
	
	# handle perfect shots etc - probably needs to be decomposed better, but ok for proof of concept and initial work
	# override in other children of GUN!!!!
	_shoot_handler()
	_handle_ammo()

func _play_shoot_animation():
	Gun_Animation.stop()
	Gun_Animation.play("Fire")
	
func _shoot_handler():
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

func _shoot(damage, bullet_scale):
	_spawn_bullet(damage, bullet_scale)


func _handle_ammo():
	EventManager.shots_fired.emit(1)
	
	_current_ammo -= 1
	if _current_ammo <= 0 and reload_full: 
		_is_reloading = true
		reload_timer.start(reload_time)

func _spawn_bullet(damage: float, size: float) -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	
	var aim_dir = Vector3(cos(rotation.z), sin(rotation.z), 0.0).normalized()
	if base_aim_spread != 0:
		var aim_deviation = randf_range(-deg_to_rad(base_aim_spread), deg_to_rad(base_aim_spread))
		aim_dir = aim_dir.rotated(Vector3(0.0, 0.0, 1.0), aim_deviation)
	
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
	bullet.speed *= bullet_velocity_multiplier
	var hb = bullet.get_node("HitboxComponent") 
	hb.hurtbox_hit.connect(func(hurtbox): enemy_hit.emit(hurtbox))

func _on_reload_timer_timeout() -> void:
	_is_reloading = false
	_current_ammo = ammo_max
	
	if active: EventManager.new_mag_loaded.emit(_current_ammo, ammo_max)
