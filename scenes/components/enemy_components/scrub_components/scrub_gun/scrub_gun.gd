extends Node3D

# The component for the Scrub enemy's gun, when Scrub is in attack phase
# aim towards the player and fire on a set timer when there is line of sight
# Attached as a child of the Scrub

## exported variables
@export_category("Gun Components")
@export var bullet_scene: PackedScene	# bullet.tscn file to spawn when firing
@export var muzzle: Marker3D			# bullet spawn at muzzle tip
@export var team_component: Node		# enemy TeamComponent reference, passed to bullets

@export_group("Normal Fire")
@export var fire_rate: float = 3		# time (seconds) between shots
@export var bullet_damage: float = 15.0		# bullet damage
@export var bullet_knockback: float = 0.0	# knockback force (can remove)
@export var bullet_scale: float = 1.0	# visual size of bullet 

# _is_firing is true when Scrub is in attack phase, will aim and fire
var _is_firing: bool
var _fire_cooldown: float = 0.0	# counts down each frame, gun can't fire until it hits 0
var _target: CharacterBody3D

# Set target to Player
# TODO: change to allow for aiming at convicts
func _ready():
	_is_firing = false
	_target = get_tree().get_nodes_in_group("Player")[0] as CharacterBody3D
	
# Active in ScrubAttack state, where player is in attack range.
# Aim toward Player's current position and fire on a cooldown timer
func _process(delta: float) -> void:
	if _is_firing:
		# Rotate gun towards Player
		var direction = _target.global_position - global_position
		direction.z = 0
		var target_angle = Vector2(direction.x, direction.y).angle()
		rotation.z = target_angle
		# Fire on cooldown
		# TODO: check if Scrub has LoS on Player and affect cooldown then
		_fire_cooldown += delta
		if _fire_cooldown > fire_rate:
			_fire_cooldown = 0
			_spawn_bullet(bullet_damage, bullet_scale)
	# When not aiming at the player, gun is aimed down
	# TODO: change for better animation once implemented
	else:
		rotation.z = -PI/2

func _spawn_bullet(damage: float, size: float) -> void:
	var scrub_bullet = bullet_scene.instantiate()
	get_tree().root.add_child(scrub_bullet)
	scrub_bullet.global_transform = muzzle.global_transform
	
	var aim_dir = Vector3(cos(rotation.z), sin(rotation.z), 0.0).normalized()
	
	# each bullet gets its own DamageHealInstance no sharing/overwriting other bullet data
	var damage_instance = DamageHealInstance.new()
	damage_instance.amount = damage
	damage_instance.is_heal = false # false = damage, not healing
	damage_instance.type = Enums.DamageType.NORMAL
	damage_instance.knockback = bullet_knockback
	damage_instance.source = get_path()
	
	scrub_bullet.initialize(aim_dir, damage_instance, team_component, size)
	
