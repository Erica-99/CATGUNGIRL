# Flee State: runs away from a close player

# From Flee State the Scrub can transition into:
#   - Attack, returns to shooting after done fleeing

extends State
class_name ScrubFlee

var actor: CharacterBody3D
var anim: AnimatedSprite3D
var target: CharacterBody3D
var flee_speed: float

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	target = blackboard["target"]
	flee_speed = blackboard["flee_speed"]

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction
	#var direction = sign(actor.global_position.x - target.global_position.x)
	#if direction != actor.facing:
		#actor.facing_changed.emit(direction)
	#anim.play("flee")
	if actor.global_position > target.global_position:
		#anim.flip_h = false;
		direction = -1
	elif actor.global_position < target.global_position:
		#anim.flip_h = true;
		direction = 1
	
	actor.facing = direction
		
	# Same logic as chase, just made negative, to move away from player
	actor.velocity.x += -(direction * flee_speed * delta)
	actor.velocity.x = clamp(actor.velocity.x, -flee_speed, flee_speed)
	
	actor.move_and_slide()
