# Chase State: Scrub moves toward detected player that is outside
#   attack range.

# From Chase State the Scrub can transition into:
#   - Attack, when in Attack range

# TODO: more intricate pathing, currently only moves left and right
#   towards player
extends State
class_name ScrubChase

# Information gained from state machine
var actor: CharacterBody3D
var anim: AnimatedSprite3D
var target: CharacterBody3D
var chase_speed: float
var chase_acceleration: float

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	target = blackboard["target"]
	chase_speed = blackboard["chase_speed"]
	chase_acceleration = blackboard["chase_acceleration"]

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction = sign(target.global_position.x - actor.global_position.x)
	actor.facing = direction
	#anim.play("chase")
	var target_velocity: float = direction * chase_speed
	actor.velocity.x = move_toward(actor.velocity.x, target_velocity, chase_acceleration * delta)
	actor.move_and_slide()
	
