extends Marker3D

@onready var base_gun: BaseGun = $".."

@export_category("Aiming")
@export var base_aim_spread: float = 0		# for weapons with imperfect aiming

@export_category("Bullet")
@export var bullet_scene: PackedScene	# bullet.tscn file to spawn when firing
@export var pierce_on_headshot: bool = false # pierces heads only
@export var bullet_knockback: float = 5.0	# knockback force (can remove)
@export var bullet_velocity_multiplier: float = 1.0 # higher = faster
@export var bullet_range: float = 40.0		# higher = further (mainly for shotgun)

@export_group("Spam Fire")
@export var spam_spread_angle: float = 5.0			# max degrees of random offset per spam shot
@export var spam_spread_increase: float = 2.0		# extra degrees added per consecutive spam shot
@export var spam_max_spread: float = 15.0			# max spread angle
@export var spam_aim_multiplier: float = 0.4		# lower = slower
@export var spam_window: float = 0.6				# seconds after firing where next shot counts as spam

var _spam_count: int = 0			# track spam count

func _spawn_bullet(damage: float, size: float) -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_transform = global_transform
	
	var aim_dir = Vector3.ZERO
	var aim_deviation = randf_range(-deg_to_rad(base_aim_spread), deg_to_rad(base_aim_spread))
	
	if base_gun.team_component.team == Enums.Team.PLAYER:
		aim_dir = Vector3(cos(rotation.z), sin(rotation.z), 0.0).normalized()
		if base_aim_spread != 0:
			aim_dir = aim_dir.rotated(Vector3(0.0, 0.0, 1.0), aim_deviation)
		
		# new spread
		if base_gun._is_spamming:
			var total_spread = deg_to_rad(minf(spam_spread_angle + spam_spread_increase * (_spam_count - 1), spam_max_spread))
			var random_offset = randf_range(-total_spread, total_spread)
			aim_dir = aim_dir.rotated(Vector3(0.0, 0.0, 1.0), random_offset)
	
	else:
		aim_dir = Vector3(cos(rotation.z), sin(rotation.z) + aim_deviation, 0.0).normalized()
	
	var damage_instance = DamageHealInstance.new()
	damage_instance.amount = damage
	damage_instance.is_heal = false
	damage_instance.type = Enums.DamageType.NORMAL
	damage_instance.knockback = bullet_knockback
	damage_instance.source = get_path()
	
	bullet.initialize(aim_dir, damage_instance, base_gun.team_component, size, pierce_on_headshot)
	bullet.speed *= bullet_velocity_multiplier
	bullet.max_range = bullet_range
	var hb = bullet.get_node("HitboxComponent") 
	hb.damage_dealt.connect(func(damage): base_gun.enemy_hit.emit(damage))

	
