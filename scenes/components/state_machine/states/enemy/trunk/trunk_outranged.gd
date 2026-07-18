extends State
class_name TrunkOutranged

# Information gained from state machine
var actor: CharacterBody3D
var anim: AnimatedSprite3D
var target: CharacterBody3D
var gun_component: Node3D
var slow_down_speed: float

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	target = blackboard["target"]
	gun_component = blackboard["gun_component"]

func enter() -> void:
	#gun_component._is_firing = true
	gun_component._bullets_fired = 0

func exit() -> void:
	gun_component._is_firing = false

func update(_delta: float) -> void:
	var direction = sign(target.global_position.x - actor.global_position.x)
	actor.facing = direction
	
	if actor.can_shoot.is_colliding():
		gun_component._is_firing = false
	else:
		gun_component._is_firing = true

func physics_update(delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, delta)
	#anim.play("idle")
	actor.move_and_slide()
