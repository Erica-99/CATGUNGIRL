extends State
class_name EnemyMove

@export var move_speed: float = 3.0
@export var anim: Animation

var destination: Vector3
var threshold: float

var target_x: float

var body: CharacterBody3D

func enter() -> void:
	# PLay Animation
	# Set Body to Enemy
	body = blackboard["actor"]
	pass

func update(_delta: float) -> void:
	# Checks if actor is in threshold range of destination
	if body.global_position.distance_to(destination) <= threshold:
		is_complete = true
	pass


func physics_update(_delta: float) -> void:
	# move enemy toward target
	var dir = (destination - body.global_position).normalized()
	body.velocity = dir * move_speed
	pass
