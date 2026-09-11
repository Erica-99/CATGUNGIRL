extends Ability
class_name BeamComponent

var actor: CharacterBody3D
var team_component: Node
@export var sniper: Node
@export var muzzle: Marker3D
@export var beam_scene: PackedScene

@export_category("Charge")
@export var charge_time: float = 0.6
var activated: bool = false
var charge_timer: float = 0.0

@export_category("Slow Down")
@export var slow_motion_scale: float = 0.25

@export_category("Beam")
@export var beam_range: float = 30.0
@export var beam_thickness: float = 0.5
@export var beam_damage: float = 40.0

@export_category("Kickback")
@export var kickback_force: float = 10.0

signal enemy_hit(damage: float)

func is_ability_enterable() -> bool:
	return sniper._current_ammo > 0

func initialise(ability_state: State, actor_blackboard: Dictionary) -> void:
	super.initialise(ability_state, actor_blackboard)
	actor = actor_blackboard["actor"]
	team_component = actor.get_node("TeamComponent")
	activated = true
	charge_timer = 0.0
	actor.velocity *= slow_motion_scale

func _physics_process(delta: float) -> void:
	if not activated:
		return
	if actor.gun_holder.current_gun != sniper:
		activated = false
		_ability_state.end_ability.emit()
		return
		
	if not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * slow_motion_scale * delta
		
	if charge_timer < charge_time and (DebugManager.infinite_ammo or sniper._current_ammo > 0):
		charge_timer += delta
	else:
		_fire_beam()
		activated = false
		_ability_state.end_ability.emit()

func _fire_beam() -> void:
	if not DebugManager.infinite_ammo and sniper._current_ammo <= 0:
		return

	var aim_dir = Vector3(cos(sniper.rotation.z), sin(sniper.rotation.z), 0.0).normalized()
	actor.velocity = -aim_dir * kickback_force
	
	# raycast decides how long the beam looks (stops at wall) NOT used to resolve damage
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(muzzle.global_position, muzzle.global_position + aim_dir * beam_range)
	query.collision_mask = 1 # Level layer only
	var result = space_state.intersect_ray(query)
	var beam_length = beam_range if result.is_empty() else muzzle.global_position.distance_to(result["position"])
	
	var beam = beam_scene.instantiate()
	get_tree().root.add_child(beam)
	beam.global_transform = muzzle.global_transform
	beam.global_transform = beam.global_transform.translated_local(Vector3(beam_length / 2.0, 0, 0))
	
	var beam_scale = Vector3(beam_length, beam_thickness, beam_thickness)
	beam.get_node("CollisionShape3D").scale = beam_scale
	beam.get_node("HitboxComponent/CollisionShape3D").scale = beam_scale
	beam.get_node("MeshInstance3D").scale = beam_scale
	
	var damage_instance = DamageHealInstance.new()
	damage_instance.amount = beam_damage
	damage_instance.is_heal = false
	damage_instance.type = Enums.DamageType.NORMAL
	damage_instance.source = get_path()
	
	beam.initialize(aim_dir, damage_instance, team_component, 1.0)
	var hb = beam.get_node("HitboxComponent")
	hb.damage_dealt.connect(func(dmg): enemy_hit.emit(dmg))
	
	sniper._time_since_last_shot = 0.0
	sniper._handle_ammo()
