extends Node3D

# bulletemitter provides the code to emit a bullet
# holds reference to a defined muzzle location (as per later attached to gun) - if no muzzle, cannot shoot etc.

# defined muzzle location
@export var muzzle: Marker3D = null
@export var bullet_scene: PackedScene	# bullet.tscn file to spawn when firing
@export var gun_link: BaseGun
@export var ammo_component: AmmoComponent

@export var audio_string_id: String = ""

@export_group("Normal Fire")
@export var fire_rate: float = 0.15			# min time (seconds) between shots
@export var full_auto: bool = true
@export var bullet_damage: float = 10.0
@export var bullet_knockback: float = 5.0	# knockback force (can remove)
@export var bullet_scale: float = 1.0
@export var bullet_velocity_multiplier: float = 1.0 # higher = faster
@export var bullet_range: float = 40.0		# higher = further (mainly for shotgun)
@export var pierce_on_headshot: bool = false # pierces heads only
@export var base_aim_spread: float = 0		# for weapons with imperfect aiming

@export_group("PLAYER Spam Fire")
@export var spam_spread_angle: float = 5.0			# max degrees of random offset per spam shot
@export var spam_spread_increase: float = 2.0		# extra degrees added per consecutive spam shot
@export var spam_max_spread: float = 15.0			# max spread angle

## semi-auto buffer
var semi_available: bool = true

# spawns a singular bullet
func _spawn_bullet(damage: float, size: float) -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	
	var aim_dir = Vector3(cos(gun_link.rotation.z), sin(gun_link.rotation.z), 0.0).normalized()
	
	if gun_link.team_component.team == Enums.Team.PLAYER:
		if base_aim_spread != 0:
			var aim_deviation = randf_range(-deg_to_rad(base_aim_spread), deg_to_rad(base_aim_spread))
			aim_dir = aim_dir.rotated(Vector3(0.0, 0.0, 1.0), aim_deviation)
		
		if gun_link._is_spamming:
			var total_spread = deg_to_rad(minf(spam_spread_angle + spam_spread_increase * (gun_link._spam_count - 1), spam_max_spread))
			var random_offset = randf_range(-total_spread, total_spread)
			aim_dir = aim_dir.rotated(Vector3(0.0, 0.0, 1.0), random_offset)
	else:
		var aim_deviation = randf_range(-deg_to_rad(base_aim_spread), deg_to_rad(base_aim_spread))
		aim_dir = aim_dir.rotated(Vector3(0.0, 0.0, 1.0), aim_deviation)
	
	# each bullet gets its own DamageHealInstance no sharing/overwriting other bullet data
	var damage_instance = DamageHealInstance.new()
	damage_instance.amount = damage
	damage_instance.is_heal = false # false = damage, not healing
	damage_instance.type = Enums.DamageType.NORMAL
	damage_instance.knockback = bullet_knockback
	damage_instance.source = get_path()
	
	bullet.initialize(aim_dir, damage_instance, gun_link.team_component, size, pierce_on_headshot)
	
	if audio_string_id:
		AudioManager.play_sfx_at_location(audio_string_id, global_position)
	
	#AudioManager.play_sfx_at_location("scrub_shot", global_position)
	bullet.speed *= bullet_velocity_multiplier
	bullet.max_range = bullet_range
	var hb = bullet.get_node("HitboxComponent")
	hb.damage_dealt.connect(func(damage): gun_link.enemy_hit.emit(damage))


# PLAYER ONLY FUNCTION
# DOES NOTHING FOR ENEMIES AS THEY USE DIRECT SHOOT CALLS
func _try_fire() -> void:
	if !ammo_component._check_if_can_shoot() and !DebugManager.infinite_ammo:
		return

	if bullet_scene == null or muzzle == null:
		print("Bullet scene or muzzle is currently null. Cannot fire.")
		return
	
	#Play Gun Animation
	_play_shoot_animation()
	
	# handle perfect shots etc - probably needs to be decomposed better, but ok for proof of concept and initial work
	# override in other children of GUN!!!!
	gun_link._shoot_handler()
	ammo_component._handle_ammo()

func _play_shoot_animation():
	gun_link.Gun_Animation.stop()
	gun_link.Gun_Animation.play("Fire")

func _shoot(damage, bullet_scale):
	_spawn_bullet(damage, bullet_scale)
