extends State
class_name MissileSpawn

@export var burst_duration := 0.5
@export var burst_velocity:= 4
@export var burst_damp = 5


var timer := 0.0
var body: CharacterBody3D
var launch_dir: Vector2


func enter():
	body = blackboard["actor"]
	
	var cone_radius := 0.4
	var x := randf_range(-cone_radius, cone_radius)
	var y := 1.0

	launch_dir = Vector2(x, y).normalized()
	
	
	timer = 0.0

func physics_update(delta):
	timer += delta
	
	
	if timer <= burst_duration:
		body.velocity.x = burst_velocity * launch_dir.x
		body.velocity.y = burst_velocity * launch_dir.y
		
	else:
		body.velocity.x = lerp(body.velocity.x, 0.0, burst_damp * delta)
		body.velocity.y = lerp(body.velocity.y, 0.0, burst_damp * delta)
		if body.velocity.y < 0.1:
			transitioned.emit(self, "missilehome")
			print("Target Locked")
	
	body.move_and_slide()
