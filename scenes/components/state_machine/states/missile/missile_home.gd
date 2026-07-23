extends State
class_name MissileHome

@export var speed := 10.0
@export var turn_rate := 3.0 

var body: CharacterBody3D
var player: CharacterBody3D

func enter():
	body = blackboard["actor"]
	player = blackboard["player"]


func physics_update(delta):
	var target_pos = player.global_position

	var desired_dir = (target_pos - body.global_position).normalized()
	var current_dir = body.velocity.normalized()
	var new_dir = current_dir.slerp(desired_dir, turn_rate * delta)

	body.velocity = new_dir * speed
	body.move_and_slide()
