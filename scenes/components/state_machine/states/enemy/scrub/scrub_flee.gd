# Flee State: runs away from a close player

# From Flee State the Scrub can transition into:
#   - Attack, returns to shooting after done fleeing

extends State
class_name ScrubFlee

var actor: CharacterBody3D
var anim: AnimatedSprite3D
var flee_speed: float

var player: CharacterBody3D

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	flee_speed = blackboard["flee_speed"]

func enter() -> void:
	player = get_tree().get_nodes_in_group("player")[0] as CharacterBody3D

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction: int
	
	if actor.global_position > player.global_position:
		#anim.flip_h = false;
		direction = -1
	elif actor.global_position < player.global_position:
		#anim.flip_h = true;
		direction = 1
	
	#anim.play("flee")
	
	# Same logic as chase, just made negative, to move away from player
	actor.velocity.x += -(direction * flee_speed * delta)
	actor.velocity.x = clamp(actor.velocity.x, -flee_speed, flee_speed)
	
	actor.time += delta
	actor.velocity.y = cos(actor.time * actor.frequency) * actor.amplitude
	
	actor.move_and_slide()
