extends CharacterBody3D
@onready var too_far_floor_detection: RayCast3D = $TooFarFloorDetection
@onready var environment_too_close: Area3D = $EnvironmentTooClose

@export_category("Node References")
@export var animator: AnimatedSprite3D
@export var state_machine: StateMachine
@onready var can_shoot: RayCast3D = $CanShoot
@onready var softCollider = $SoftCollider

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
@export var chase_acceleration: float = 5.0
@export var flee_speed: float
@export var flee_acceleration: float = 5.0
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
@export var frequency: float = 3.0
@export var amplitude: float = 2.0

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
		"chase_acceleration": chase_acceleration,
		"flee_speed": flee_speed,
		"flee_acceleration": flee_acceleration,
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
	var added_velo = 0
	if !too_far_floor_detection.is_colliding():
		added_velo += -1
	else:
		if environment_too_close.get_overlapping_bodies():
			added_velo += 1
	
	time += delta
	velocity.y = cos(time * frequency) * amplitude + added_velo
	global_position.z = 0
	#print("velo y calced is : " + str(velocity.y))
	
	# Soft Collision physics effects to avoid overlap.
	if softCollider.is_colliding():
		var push_vel = softCollider.get_push_vector() * delta * 12
		push_vel.z = 0
		velocity += push_vel
		var vertical_push: float = 0.0
		
		for area in softCollider.get_overlapping_areas():
			if area == softCollider:
				continue
			
			var other_scrub = area.get_parent()
			
			if other_scrub == self:
				continue
			
			var height_difference: float = global_position.y - other_scrub.global_position.y
			
			if abs(height_difference) <= 0.15:
				if get_instance_id() > other_scrub.get_instance_id():
					vertical_push += 1.0
				else:
					vertical_push -= 1.0
			else:
				vertical_push += sign(height_difference)
		
		velocity.y += vertical_push * delta * 50
	
	move_and_slide()
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

func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	if !detected_player && !is_dead:
		detected_player = true
		state_machine.on_child_transition(state_machine.current_state, "scrubchase")
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
