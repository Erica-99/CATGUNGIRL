# Idle State: Convict stands still, ready to detect
#    TODO: add idle dialogue

# Idle moves to Patrol and Alert

extends State

var actor: CharacterBody3D
var anim: AnimatedSprite3D
var slow_down_speed: float

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	slow_down_speed = blackboard["slow_down_speed"]

func physics_update(_delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0,
	slow_down_speed * _delta)
	#anim.play("idle")
	actor.move_and_slide()
