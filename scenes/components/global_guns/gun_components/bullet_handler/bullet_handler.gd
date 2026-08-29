extends Node3D

class_name BulletHandler

@onready var gun: ImprovedGun = $".."

@export var bullet_scene: PackedScene	# bullet.tscn file to spawn when firing

# muzzle needs to be external from base gun to prevent issues around different gun lengths etc.
@onready var muzzle: Marker3D = $Muzzle

var _spam_count: int = 0			# track spam count

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _spawn_bullet(damage: float, size: float) -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	
	var aim_dir = Vector3(cos(rotation.z), sin(rotation.z), 0.0).normalized()
	if gun.base_aim_spread != 0:
		var aim_deviation = randf_range(-deg_to_rad(gun.base_aim_spread), deg_to_rad(gun.base_aim_spread))
		aim_dir = aim_dir.rotated(Vector3(0.0, 0.0, 1.0), aim_deviation)
	
	# if is player, handle player spamming
	if gun.team_component.team == Enums.Team.PLAYER:
		# new spread
		if gun._is_spamming:
			var total_spread = deg_to_rad(minf(gun.spam_spread_angle + gun.spam_spread_increase * (_spam_count - 1), gun.spam_max_spread))
			var random_offset = randf_range(-total_spread, total_spread)
			aim_dir = aim_dir.rotated(Vector3(0.0, 0.0, 1.0), random_offset)
	
	var damage_instance = DamageHealInstance.new()
	damage_instance.amount = damage
	damage_instance.is_heal = false
	damage_instance.type = Enums.DamageType.NORMAL
	damage_instance.knockback = gun.bullet_knockback
	damage_instance.source = get_path()
	
	bullet.initialize(aim_dir, damage_instance, gun.team_component, size, gun.pierce_on_headshot)
	bullet.speed *= gun.bullet_velocity_multiplier
	bullet.max_range = gun.bullet_range
	var hb = bullet.get_node("HitboxComponent") 
	hb.damage_dealt.connect(func(damage): gun.enemy_hit.emit(damage))
