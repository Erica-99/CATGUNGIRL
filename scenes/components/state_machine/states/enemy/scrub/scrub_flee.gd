# Flee State: runs away from a close player

# From Flee State the Scrub can transition into:
#   - Attack, returns to shooting after done fleeing

extends State
class_name ScrubFlee

var actor: CharacterBody3D
var anim: AnimatedSprite3D
var target: CharacterBody3D
var flee_speed: float
var flee_acceleration: float

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	target = blackboard["target"]
	flee_speed = blackboard["flee_speed"]
	flee_acceleration = blackboard["flee_acceleration"]

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction: float = sign(actor.global_position.x - target.global_position.x)
	
	if direction == 0.0:
		direction = actor.facing
	
	actor.facing = -direction
		
	# Same logic as chase
	var target_velocity: float = direction * flee_speed
	actor.velocity.x = move_toward(actor.velocity.x, target_velocity, flee_acceleration * delta)
	actor.move_and_slide()


func _on_flee_area_3d_body_exited(body: Node3D) -> void:
	if !actor.is_dead:
		transitioned.emit(self, "scrubattack")
