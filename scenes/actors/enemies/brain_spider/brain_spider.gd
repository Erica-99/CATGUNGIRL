extends CharacterBody3D
class_name BrainSpider

@onready var detection_area_3d: Area3D = $DetectionArea3D
@onready var explosion_area_3d: Area3D = $ExplosionArea3D
@onready var detonation_area_3d: Area3D = $DetonationArea3D
@onready var explosion_collision_shape: CollisionShape3D = $ExplosionArea3D/CollisionShape3D
@onready var explosion_visual: AnimatedSprite3D = $Visuals/ExplosionVisual
@onready var body_visual: AnimatedSprite3D = $Visuals/AnimatedSprite3D
@onready var softCollider = $SoftCollider
@onready var health_comp = $HealthComponent

@export_category("Node References")
@export var animator: AnimationPlayer
@export var state_machine: StateMachine

@export_category("Starting State Variables")
@export var start_aggroed: bool
@export var start_idle: State
@export var start_aggro: State

@export_category("Brain Spider Type")
enum SpiderMode {
	FLOOR,
	WALL_CEILING
}
@export var spider_mode: SpiderMode = SpiderMode.FLOOR

@export_category("Stat Variables")
@export var move_speed: float = 8.0
@export var acceleration: float = 20.0
@export var gravity: float = 50.0

@export_category("Explosion Variables")
@export var explosion_damage: float = 25.0
@export var explosion_knockback: float = 10.0
@export var explosion_delay: float = 1.0

@export_category("Death Variables")
@export var death_duration: float = 0.5

var is_dying: bool = false
var is_dead: bool = false
var target: CharacterBody3D = null

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
		state_machine.initial_state = start_aggro
	else:
		state_machine.initial_state = start_idle
	
	explosion_visual.visible = false
	match_explosion_visual_to_radius()
	state_machine.init(blackboard)
	health_comp.killed.connect(_on_health_component_killed)

func _on_health_component_killed(killing_blow: DamageHealInstance, health_before_death: Variant) -> void:
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
	explosion_visual.scale = Vector3.ONE * explosion_radius

func show_explosion_effect() -> void:
	body_visual.visible = false
	explosion_visual.visible = true
	explosion_visual.frame = 0
	explosion_visual.play("default")
