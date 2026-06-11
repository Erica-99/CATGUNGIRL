# Superjump State: short pause, jump towards player position
# TODO: implement a real trigger when doing advanced pathfinding

extends State

var actor: CharacterBody3D
var anim: AnimationPlayer
var jump_force: float
var slow_down_speed: float
var target: CharacterBody3D
var direction: int
var has_jumped: bool = false
var accel_speed: float
var chase_speed: float
var windup_duration: float	# how long convict pauses for before jump
#var superjump_force: float	# upwards force
#var superjump_speed: float	# horizontal force

var windup_timer: float = 0.0

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	jump_force = blackboard["jump_force"]
	slow_down_speed = blackboard["slow_down_speed"]
	accel_speed = blackboard["accel_speed"]
	chase_speed = blackboard["chase_speed"]
	windup_duration = blackboard["windup_duration"]
	#superjump_force = blackboard["superjump_force"]
	#superjump_speed = blackboard["superjump_speed"]

func enter() -> void:
	target = get_tree().get_nodes_in_group("player")[0] as CharacterBody3D
	actor.velocity = Vector3.ZERO
	windup_timer = 0.0
	has_jumped = false
	# anim.play("ConvictSuperjumpWindup")

func update(_delta: float) -> void:
	if !has_jumped:
		windup_timer += _delta

func physics_update(_delta: float) -> void:
	if actor.global_position.x > target.global_position.x:
		direction = -1
	elif actor.global_position.x < target.global_position.x:
		direction = 1
		
	if actor.is_on_floor():
		if !has_jumped and windup_timer >= windup_duration:
			superjump()
		# start charging jump
		elif !has_jumped:
			anim.play("Run")
			actor.velocity.x = move_toward(actor.velocity.x, chase_speed * -direction * 0.25, accel_speed * _delta)
		# back to chase after jump
		elif has_jumped:
			actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * _delta)
			transitioned.emit(self, "convictchase")
	actor.move_and_slide()

func exit() -> void:
	has_jumped = false
	windup_timer = 0.0

func superjump() -> void:
	actor.velocity = Vector3.ZERO
	
	# Calculate force needed to jump at target
	# At the moment the 50 represents gravity, TODO: change gravity to projects settings
	actor.velocity.x += target.global_position.x - actor.global_position.x
	actor.velocity.y += sqrt(2 * 50 * abs(target.global_position.y - actor.global_position.y)) * 1.1
	#actor.velocity.x += superjump_speed * direction
	has_jumped = true
	#anim.play("ConvictSuperjump")
