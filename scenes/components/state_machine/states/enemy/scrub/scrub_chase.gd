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

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	target = blackboard["target"]
	chase_speed = blackboard["chase_speed"]

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
	
	actor.velocity.x += direction * chase_speed * delta
	actor.velocity.x = clamp(actor.velocity.x, -chase_speed, chase_speed)
	
	actor.move_and_slide()
	
