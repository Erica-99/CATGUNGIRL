extends State
class_name MissileHomeIn

@export var acceleration : float = 2.0
@export var max_speed : float = 20
@export var turn_rate : float = 2

var body : CharacterBody3D
var player: CharacterBody3D
var current_speed : float

func enter():
	body = blackboard["actor"]
	player = blackboard["player"]
	current_speed = 0

func physics_update(delta):
	# Ensure player is present
	if not is_instance_valid(player):
		return

	# Get Target Direction
	var to_player: Vector3 = Vector3(
		player.global_position.x - body.global_position.x,
		player.global_position.y - body.global_position.y,
		0
		)
	
	var target_dir: Vector3 = to_player.normalized()
	
	# Determine Current Direction
	var current_dir: Vector3 = Vector3.UP.rotated(Vector3(0,0,1), body.rotation.z)
	
	# Accelerate
	current_speed = lerp(current_speed, max_speed, acceleration * delta)
	
	# Steer (find new direction)
	var new_dir = current_dir.slerp(target_dir, turn_rate * delta)
	
	

	# Apply Velocity
	body.velocity.x = new_dir.x * current_speed
	body.velocity.y = new_dir.y * current_speed
	body.velocity.z = 0
	
	body.move_and_slide()
	
	# Rotate to match new direction
	var angle = Vector2(new_dir.x, new_dir.y).angle()
	print(angle)
	body.rotation.z = angle + 3*PI/2
	
	# Collision Check
	if body.get_last_slide_collision() != null:
		print("Collided")
		transitioned.emit(self, "missiledetonate")
