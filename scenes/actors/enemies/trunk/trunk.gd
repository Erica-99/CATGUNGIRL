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

@export_category("Stat Variables")
@export var direction: int = 1
@export var move_speed: float = 10
@export var patrol_speed: float
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
var in_attacking_range: bool

signal facing_changed(scrub: CharacterBody3D)

var is_dead: bool = false
var blackboard: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Blackboard contains the information states will use
	blackboard = {
		# Actor for movement stats
		"actor": self,
		"anim": animator,
		"direction": direction,
		"gun_component": gun_component,
		"patrol_speed": patrol_speed,
		"chase_speed": chase_speed,
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
	move_and_slide()

func _on_health_component_killed(killing_blow: DamageHealInstance, health_before_death: Variant) -> void:
	# Possibly implement knockback affects here
	is_dead = true
	state_machine.on_child_transition(state_machine.current_state, "trunkdeath")
