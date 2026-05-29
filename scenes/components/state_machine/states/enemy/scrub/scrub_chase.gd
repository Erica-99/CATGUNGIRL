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
var chase_speed: float

var player: CharacterBody3D

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	chase_speed = blackboard["chase_speed"]

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
	
	#anim.play("chase")
	
	actor.velocity.x += direction * chase_speed * delta
	actor.velocity.x = clamp(actor.velocity.x, -chase_speed, chase_speed)
	
	actor.time += delta
	actor.velocity.y = cos(actor.time * actor.frequency) * actor.amplitude
	
	actor.move_and_slide()
	
