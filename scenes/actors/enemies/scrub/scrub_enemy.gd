extends CharacterBody3D

@export_category("Node References")
@export var animator: AnimatedSprite3D
@export var state_machine: StateMachine
@onready var can_shoot: RayCast3D = $CanShoot

var is_dead: bool = false

@export_category("Starting State Variables")
@export var start_aggroed: bool
@export var patroller: bool
@export var start_idle: State
@export var start_patrol: State
@export var start_aggro: State

@onready var health_comp = $HealthComponent
@export var gun_component: Node3D
@export var grenade: PackedScene

@export_category("Stat Variables")
@export var direction: int = 1
@export var move_speed: float = 10
@export var patrol_speed: float
@export var chase_speed: float
@export var flee_speed: float
@export var slow_down_speed: float = 30
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

# Maybe this should move to the Scrub Gun
@export_category("State Controlling Variables")
@export var detected_player: bool = false
var in_attacking_range: bool

var time: float = 0.0
@export var frequency: float = 2.0
@export var amplitude: float = 5.0

signal facing_changed(scrub: CharacterBody3D)

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
		"grenade": grenade,
		"patrol_speed": patrol_speed,
		"chase_speed": chase_speed,
		"flee_speed": flee_speed,
		"slow_down_speed": slow_down_speed,
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
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if in_attacking_range:
		can_shoot.target_position = can_shoot.to_local(get_tree().get_first_node_in_group("player").global_position)

func _physics_process(delta: float) -> void:
	pass
	# Direction facing transformation
	#if velocity.x < 0: # LEFT
		#direction = -1
		#animator.flip_h = true
	#elif velocity.x > 0: # RIGHT
		#direction = 1
		#animator.flip_h = false
	
	#direction = sign(velocity.x)
	#if direction != facing && direction != 0.0:
		#facing_changed.emit(direction)


# health comp killed taken from convict code
func _on_health_component_killed(killing_blow: DamageHealInstance, health_before_death: Variant) -> void:
	# Possibly implement knockback affects here
	is_dead = true
	state_machine.on_child_transition(state_machine.current_state, "scrubdeath")

# When player enters detection range, move to attack
# For a possible specific case, if they are in detection but
# not attack range move to chase.
# TODO: Improve by utilising more detection logic than just an area
func _on_detection_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") && !is_dead:
		if detected_player == false:
			detected_player = true
			print("Player entered detection area")
			if in_attacking_range:
				state_machine.on_child_transition(state_machine.current_state, "scrubattack")
				print("Attacking Player")
			else:
				state_machine.on_child_transition(state_machine.current_state, "scrubchase")

# When player enters attack range, check off that theyre in range
# If player has been detected, move to attack state
func _on_att_range_area_3d_body_entered(body):
	if body.is_in_group("player") && !is_dead:
		in_attacking_range = true
		if detected_player:
			state_machine.on_child_transition(state_machine.current_state, "scrubattack")
			print("Attacking Player")

# When player leaves attack range, check of that they're out of range
# If they have been detected, move to chase
func _on_att_range_area_3d_body_exited(body):
	if body.is_in_group("player") && !is_dead:
		in_attacking_range = true
		if detected_player:
			state_machine.on_child_transition(state_machine.current_state, "scrubchase")
			print("Chasing Player")

# When player enters flee range, move to flee
func _on_flee_area_3d_body_entered(body):
	if body.is_in_group("player") && !is_dead:
		state_machine.on_child_transition(state_machine.current_state, "scrubflee")
		print("Fleeing Player")

# When player exits flee range, move to attack
# TODO: Improve flee logic so that Scrub tries to make distance/
#    stops fleeing if they are blocked.
func _on_flee_area_3d_body_exited(body):
	if body.is_in_group("player") && !is_dead:
		state_machine.on_child_transition(state_machine.current_state, "scrubattack")

func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	if !detected_player && !is_dead:
		detected_player = true
		state_machine.on_child_transition(state_machine.current_state, "scrubchase")
		print("Chasing Player")
	if damage_or_heal_instance.amount > head_hitstun_threshold:
		_apply_hitstun(head_hitstun_duration)
	elif damage_or_heal_instance.amount == body_hitstun_threshold:
		_apply_hitstun(body_hitstun_duration)

func _apply_hitstun(duration: float) -> void:
	velocity.x = 0.0	# remove velocity.x and velocity.z and replace with
	velocity.z = 0.0	# velocity = Vector3.ZERO if scrubs should fall on hitstun
	#animator.pause()
	#await get_tree().create_timer(duration).timeout
	#animator.play()
