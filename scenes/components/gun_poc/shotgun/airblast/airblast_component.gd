extends Ability
class_name AirblastComponent

var actor: CharacterBody3D
@export var shotgun: Node
var state_machine: StateMachine
var team_component: Node

@export_category("Blast Attributes")
var activated: bool = false
@export var charge_time: float = 0.5
var charge_timer: float = 0
@export var slow_down_speed: float = 30 # how fast you slow down
@export var slow_down_target: float = 0.3 # what speed is the slow down aiming for (percentage of current speed)
var slow_target_x: float
var slow_target_y: float
@export var launch_speed: float = 50
@export var blast_object: PackedScene
@export var blast_base_damage: float = 20
@export var blast_base_knockback: float = 20

signal enemy_hit(hurtbox: Area3D)

func is_ability_enterable() -> bool:
	return shotgun._current_ammo > 0

func initialise(ability_state: State, actor_blackboard: Dictionary) -> void:
	super.initialise(ability_state, actor_blackboard)
	actor = actor_blackboard["actor"]
	team_component = actor.get_node("TeamComponent")
	activated = true
	charge_timer = 0
	slow_target_x = actor.velocity.x * slow_down_target
	slow_target_y = actor.velocity.y * slow_down_target

func _physics_process(_delta: float) -> void:
	if activated:
		shotgun.single_reload_timer = 0 # to stop from reloading while using ability
		# To cancel when gun is swapped
		if actor.gun_holder.current_gun != shotgun:
			_ability_state.end_ability.emit()
			activated = false
		
		# While charging blast
		if charge_timer < charge_time and shotgun._current_ammo != 0:
			charge_timer += _delta
			actor.velocity.x = move_toward(actor.velocity.x, slow_target_x, slow_down_speed * _delta)
			actor.velocity.y = move_toward(actor.velocity.y, slow_target_y, slow_down_speed * _delta)
		# When finished charging
		else:
			_fire_blast()
			charge_timer = 0
			activated = false
			_ability_state.end_ability.emit()

# Create a static projectile that knocks back enemies where aiming, and launch player
# in the opposite direction
func _fire_blast():
	if shotgun._current_ammo > 0:
		# create the airblast projectile - static, scales to ammo
		var blast = blast_object.instantiate()
		get_tree().root.add_child(blast)
		var aim_dir = Vector3(cos(shotgun.rotation.z), sin(shotgun.rotation.z), 0.0).normalized()
		blast.global_transform = shotgun.muzzle.global_transform.translated(aim_dir * (shotgun._current_ammo + 1)) # offset spawn pos
		
		var damage_instance = DamageHealInstance.new()
		damage_instance.amount = blast_base_damage * shotgun._current_ammo
		damage_instance.is_heal = false
		damage_instance.type = Enums.DamageType.NORMAL
		damage_instance.knockback = blast_base_knockback * shotgun._current_ammo
		damage_instance.source = get_path()
		
		blast.initialize(aim_dir, damage_instance, team_component, shotgun._current_ammo) # ammo count for scale
		var hb = blast.get_node("HitboxComponent") 
		hb.hurtbox_hit.connect(func(hurtbox): enemy_hit.emit(hurtbox)) # Will need to modify this to work with new enemy_hit signal behaviour in dev.
		# This handles the launch
		actor.velocity = -aim_dir * (launch_speed * shotgun._current_ammo)
		
		var prev_ammo = shotgun._current_ammo
		shotgun._current_ammo = 0
		EventManager.shots_fired.emit(prev_ammo)
	
