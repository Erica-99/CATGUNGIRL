extends State
class_name TrunkIdle

# Information gained from state machine
var actor: CharacterBody3D
var anim: AnimatedSprite3D
var slow_down_speed: float

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, delta)
	#anim.play("idle")
	
	actor.move_and_slide()
