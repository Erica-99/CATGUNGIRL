extends State
class_name MissileSpawn

@export var burst_duration := 0.5
@export var burst_velocity:= 4
@export var burst_damp = 5
@export var spin_count: int = 4
@export var spin_damp := 1


var timer := 0.0
var body: CharacterBody3D
var spin_progress: int


func enter():
	body = blackboard["actor"]
	body.velocity.x = 0
	body.velocity.z = 0
	body.velocity.y = burst_velocity
	timer = 0.0
	spin_progress = spin_count * 360

func physics_update(delta):
	timer += delta
	
	spin_progress = lerp(spin_progress, 0, spin_damp * delta)
	body.rotation.z = deg_to_rad(spin_progress)
	
	if timer <= burst_duration:
		body.velocity.y = burst_velocity
		
	else:
		body.velocity.y = lerp(body.velocity.y, 0.0, burst_damp * delta)
		if body.velocity.y < 0.1 and body.rotation.z < 0.1:
			transitioned.emit(self, "missilehome")
			print("Target Locked")
	
	body.move_and_slide()
