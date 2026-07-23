extends State
class_name MissileSpawn

@export var launch_duration := 0.3
@export var upward_speed := 10.0

var timer := 0.0
var body

func enter():
	body = blackboard["actor"]
	timer = 0.0

func physics_update(delta):
	timer += delta
	body.velocity = Vector3.UP * upward_speed
	body.move_and_slide()

	if timer >= launch_duration:
		transitioned.emit(self, "missilehome")
		print("Switch to Home")
