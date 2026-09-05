extends CharacterBody3D
class_name BrainSpider

@onready var detection_area_3d: Area3D = $DetectionArea3D
@onready var explosion_area_3d: Area3D = $ExplosionArea3D
@onready var detonation_area_3d: Area3D = $DetonationArea3D
@onready var body_hurtbox: Area3D = $BodyHurtbox
@onready var explosion_collision_shape: CollisionShape3D = $ExplosionArea3D/CollisionShape3D
@onready var laser_origin: Marker3D = $SpiderPivot/LaserOrigin
@onready var laser: Node3D = $SpiderPivot/LaserOrigin/Laser
@onready var laser_ray: RayCast3D = $SpiderPivot/LaserOrigin/Laser/RayCast3D
@onready var softCollider = $SoftCollider
@onready var health_comp = $HealthComponent
@onready var team_component = $TeamComponent
@onready var brain_spider_visuals: BrainSpiderVisuals = $SpiderPivot

@export_category("Node References")
@export var animator: AnimationPlayer
@export var state_machine: StateMachine

@export_category("Starting State Variables")
@export var start_aggroed: bool
@export var start_idle: State
@export var start_floor_aggro: State
@export var start_surface_aggro: State

@export_category("Brain Spider Type")
enum SpiderMode {
	FLOOR,
	WALL_CEILING
}
@export var spider_mode: SpiderMode = SpiderMode.FLOOR

enum SurfaceType {
	CEILING,
	LEFT_WALL,
	RIGHT_WALL
}
@export var surface_type: SurfaceType = SurfaceType.CEILING

@export_category("Stat Variables")
@export var move_speed: float = 8.0
@export var acceleration: float = 20.0
@export var gravity: float = 50.0

@export_category("Explosion Variables")
@export var explosion_damage: float = 25.0
@export var explosion_knockback: float = 10.0
@export var explosion_delay: float = 1.0

@export_category("Laser Variables")
@export var laser_track_time: float = 2.0
@export var laser_lock_time: float = 0.5
@export var laser_cooldown: float = 3.5
@export var laser_damage: float = 20.0
@export var laser_scene: PackedScene
@export var laser_size: float = 0.5

@export_category("Death Variables")
@export var death_duration: float = 0.5
@export var fall_death_max_time: float = 1.5

@export_category("Damage Multiplier Variables")
@export var spider_damage_multiplier: float = 1.0
@export var turret_damage_multiplier: float = 0.5

@export_category("Animation Timing")
@export var morph_turret_time: float = 0.7
@export var morph_spider_time: float = 0.7

var is_dying: bool = false
var is_dead: bool = false
var target: CharacterBody3D = null
var laser_cooldown_timer: float = 0.0
var locked_laser_direction: Vector3 = Vector3.RIGHT
var is_in_turret_form: bool = false
var blackboard: Dictionary

func _ready() -> void:
	blackboard = {
		"actor": self,
		"anim": animator,
		"detection_area": detection_area_3d,
		"explosion_area": explosion_area_3d,
		"detonation_area": detonation_area_3d,
		"target": get_tree().get_first_node_in_group("player") as CharacterBody3D,
	}
	
	if start_aggroed:
		if spider_mode == SpiderMode.WALL_CEILING:
			state_machine.initial_state = start_surface_aggro
		else:
			state_machine.initial_state = start_floor_aggro
	else:
		state_machine.initial_state = start_idle
	
	laser.visible = false
	match_explosion_visual_to_radius()
	state_machine.init(blackboard)
	brain_spider_visuals.apply_surface_rotation()
	health_comp.killed.connect(_on_health_component_killed)

func _on_health_component_killed(_killing_blow: DamageHealInstance, _health_before_death: Variant) -> void:
	start_death()

func start_death() -> void:
	if is_dying or is_dead:
		return
	
	is_dying = true
	velocity = Vector3.ZERO
	
	state_machine.on_child_transition(state_machine.current_state, "brainspiderdeath")

func damage_players_in_explosion_area() -> void:
	for body in explosion_area_3d.get_overlapping_bodies():
		if !body.is_in_group("player"):
			continue
		
		var player_health: HealthComponent = body.get_node_or_null("HealthComponent")
		
		if player_health == null:
			continue
		
		var damage_instance = DamageHealInstance.new()
		damage_instance.amount = explosion_damage
		damage_instance.is_heal = false
		damage_instance.type = Enums.DamageType.EXPLOSIVE
		damage_instance.knockback = explosion_knockback
		damage_instance.source = get_path()
		player_health.take_damage_or_heal(damage_instance)

func apply_soft_collision(delta: float) -> void:
	if softCollider.is_colliding():
		var push_vel = softCollider.get_push_vector() * delta * 12
		push_vel.z = 0
		velocity += push_vel

func die() -> void:
	if is_dead:
		return
	
	is_dead = true
	velocity = Vector3.ZERO
	
	EventManager.enemy_killed.emit(self)
	queue_free()

func match_explosion_visual_to_radius() -> void:
	if !(explosion_collision_shape.shape is SphereShape3D):
		return
	
	var explosion_radius: float = explosion_collision_shape.shape.radius
	brain_spider_visuals.set_explosion_visual_radius(explosion_radius)

func show_explosion_effect() -> void:
	brain_spider_visuals.show_explosion_visual()

func get_surface_move_axis() -> Vector3:
	match surface_type:
		SurfaceType.CEILING:
			return Vector3.RIGHT
		SurfaceType.LEFT_WALL:
			return Vector3.UP
		SurfaceType.RIGHT_WALL:
			return Vector3.UP
	
	return Vector3.RIGHT

func get_surface_gravity_direction() -> Vector3:
	match surface_type:
		SurfaceType.CEILING:
			return Vector3.UP
		SurfaceType.LEFT_WALL:
			return Vector3.LEFT
		SurfaceType.RIGHT_WALL:
			return Vector3.RIGHT
	
	return Vector3.DOWN

func has_line_of_sight() -> bool:
	if target == null or !is_instance_valid(target):
		return false
	
	aim_laser()
	laser_ray.force_raycast_update()
	
	if !laser_ray.is_colliding():
		return false
	
	var collider = laser_ray.get_collider()
	
	if collider == null:
		return false
	
	return collider.is_in_group("player")
	
func aim_laser() -> void:
	if target == null or !is_instance_valid(target):
		return
	
	var direction: Vector3 = target.global_position - laser_origin.global_position
	direction.z = 0
	
	if direction == Vector3.ZERO:
		return
	
	var target_angle: float = Vector2(direction.x, direction.y).angle()
	laser_origin.global_rotation.z = target_angle

func fire_laser() -> void:
	if laser_scene == null:
		return
	
	var beam_start: Vector3 = laser_origin.global_position
	var beam_end: Vector3 = beam_start + locked_laser_direction * laser_ray.target_position.length()
	laser_ray.force_raycast_update()
	if laser_ray.is_colliding():
		beam_end = laser_ray.get_collision_point()
	
	var beam_length: float = beam_start.distance_to(beam_end)
	var beam_midpoint: Vector3 = beam_start + locked_laser_direction * (beam_length * 0.5)
	var damage_instance = DamageHealInstance.new()
	damage_instance.amount = laser_damage
	damage_instance.is_heal = false
	damage_instance.type = Enums.DamageType.NORMAL
	damage_instance.source = get_path()
	var laser_beam = laser_scene.instantiate()
	get_tree().root.add_child(laser_beam)
	laser_beam.initialize(locked_laser_direction, damage_instance, team_component, 1.0)
	laser_beam.global_position = beam_midpoint
	laser_beam.global_rotation.z = Vector2(locked_laser_direction.x, locked_laser_direction.y).angle()
	laser_beam.scale = Vector3(beam_length, laser_size, laser_size)

func set_spider_damage_multiplier() -> void:
	if body_hurtbox == null:
		return
	
	body_hurtbox.damage_multiplier = spider_damage_multiplier

func set_turret_damage_multiplier() -> void:
	if body_hurtbox == null:
		return
	
	body_hurtbox.damage_multiplier = turret_damage_multiplier

func show_spider_visual() -> void:
	brain_spider_visuals.show_spider_visual()

func is_explosion_effect_playing() -> bool:
	return brain_spider_visuals.is_explosion_playing()
