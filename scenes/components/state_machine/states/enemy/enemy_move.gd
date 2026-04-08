extends State
class_name EnemyMove

@export var move_speed: float = 3.0
@export var anim: Animation

var destination: Vector3
var threshold: float
var flat_dest: Vector3

var target_x: float

var body: CharacterBody3D
var animator: AnimatedSprite3D

func enter() -> void:
	# PLay Animation
	animator = blackboard["anim"]
	animator.modulate = Color(0.0, 0.5, 0.0, 1.0)
	# Set Body to Enemy
	body = blackboard["actor"]
	flat_dest = destination
	flat_dest.y = body.global_position.y
	pass

func update(_delta: float) -> void:
	# Checks if actor is in threshold range of destination
	if body.global_position.distance_to(flat_dest) <= threshold:
		is_complete = true
	pass


func physics_update(_delta: float) -> void:
	# move enemy toward target
	var dir = (flat_dest - body.global_position).normalized()
	body.velocity.x = dir.x * move_speed
	body.velocity.z = dir.z * move_speed
	body.move_and_slide()
	pass
