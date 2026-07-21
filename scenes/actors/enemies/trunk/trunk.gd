extends CharacterBody3D

@export_category("Node References")
@export var animator: AnimatedSprite3D
@export var state_machine: StateMachine

@export_category("Starting State Variables")
@export var start_aggroed: bool
@export var patroller: bool
@export var start_idle: State
@export var start_patrol: State
@export var start_aggro: State

@onready var health_comp = $HealthComponent
@export var gun_component: Node3D

@export_category("Autoswitch State Variables")
@export var min_idle_time: float = 1.0
@export var max_idle_time: float = 3.0
@export var min_patrol_time: float = 4.0
@export var max_patrol_time: float = 6.0

@export_category("Stat Variables")
@export var direction: int = 1
@export var move_speed: float = 10
@export var chase_speed: float
var facing: float = 1.0:
	set(value):
		if value != facing:
			facing = value
			facing_changed.emit(self)

@export_category("Hitstun Variables")
@export var body_hitstun_threshold: float
@export var body_hitstun_duration: float
@export var head_hitstun_threshold: float
@export var head_hitstun_duration: float

@export_category("State Controlling Variables")
@export var detected_player: bool = false

@export_category("Patrol State Modifiers")
@export var patrol_speed: float
@export var elapsed_direction_switch: float

@export_category("Melee State Modifiers")
@export var xpos_distance_to_melee: float
@export var melee_stop_speed: float
@export var melee_windup_time: float = 0.5
@export var melee_lunge_distance: float = 3.0
@export var melee_lunge_duration: float = 0.2
@export var melee_recovery_time: float = 5.0

@export_category("Attack Variables")
@export var melee_damage: float = 30.0
@export var melee_hitbox: Area3D
var damage_instance: DamageHealInstance = DamageHealInstance.new()

var in_attacking_range: bool

signal facing_changed(scrub: CharacterBody3D)

var is_dead: bool = false
var blackboard: Dictionary

const GRAVITY = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damage_instance.amount = melee_damage
	damage_instance.is_heal = false
	damage_instance.type = Enums.DamageType.NORMAL
	damage_instance.knockback = 0
	damage_instance.source = get_path()
	melee_hitbox.damage_or_heal_instance = damage_instance
	
	# Blackboard contains the information states will use
	blackboard = {
		# Actor for movement stats
		"actor": self,
		"anim": animator,
		"direction": direction,
		"gun_component": gun_component,
		"patrol_speed": patrol_speed,
		"chase_speed": chase_speed,
		"min_idle_time": min_idle_time,
		"max_idle_time": max_idle_time,
		"min_patrol_time": min_patrol_time,
		"max_patrol_time": max_patrol_time,
		"elapsed_direction_switch": elapsed_direction_switch,
		"xpos_distance_to_melee": xpos_distance_to_melee,
		"melee_stop_speed": melee_stop_speed,
		"melee_hitbox": melee_hitbox,
		"melee_damage": melee_damage,
		"melee_windup_time": melee_windup_time,
		"melee_lunge_distance": melee_lunge_distance,
		"melee_lunge_duration": melee_lunge_duration,
		"melee_recovery_time": melee_recovery_time,
		"target": get_tree().get_first_node_in_group("player") as CharacterBody3D,
	}
	# Change initial state based on Inspector values
	if start_aggroed:
		state_machine.initial_state = start_aggro
	else:
		if patroller:
			state_machine.initial_state = start_patrol
		else:
			state_machine.initial_state = start_idle
	# Initialise state machine with Scrub information
	state_machine.init(blackboard)
	
func _process(delta):
	pass

func _physics_process(delta: float) -> void:
	velocity.y -= GRAVITY * delta
	move_and_slide()

func _on_health_component_killed(killing_blow: DamageHealInstance, health_before_death: Variant) -> void:
	# Possibly implement knockback affects here
	is_dead = true
	state_machine.on_child_transition(state_machine.current_state, "trunkdeath")

func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	if !detected_player && !is_dead:
		detected_player = true
		state_machine.on_child_transition(state_machine.current_state, "trunkchase")
