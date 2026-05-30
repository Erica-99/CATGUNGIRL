# Attack State: stand still and shoot Player in attack range

# Attack after being Alerted and Player is in range

# From Attack State the Scrub can transition into:
#   - Grenade, after a set time/condition, the scrub will throw a grenade
#   - Flee, if player gets too close, try to run away
#   - Chase, if player gets out of attack range, move into attack range

extends State
class_name ScrubAttack

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
	slow_down_speed = blackboard["slow_down_speed"]

func enter() -> void:
	gun_component._is_firing = true
	gun_component._bullets_fired = 0

func exit() -> void:
	gun_component._is_firing = false

func update(_delta: float) -> void:
	var direction = sign(target.global_position.x - actor.global_position.x)
	if direction != actor.facing:
		actor.facing_changed.emit(direction)

func physics_update(delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * delta)
	#anim.play("idle")
	actor.time += delta
	actor.velocity.y = cos(actor.time * actor.frequency) * actor.amplitude
	actor.move_and_slide()
