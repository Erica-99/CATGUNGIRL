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
	var to_player: Vector2 = Vector2(
		player.global_position.x - body.global_position.x,
		player.global_position.y - body.global_position.y
		)
	
	var target_dir = to_player.normalized()
	
	# Determine Current Direction
	var vel: Vector2 = Vector2(body.velocity.x, body.velocity.y)
	var current_dir = vel.normalized()
	
	# Accelerate
	current_speed = lerp(current_speed, max_speed, acceleration * delta)
	
	# Steer (find new direction)
	var speed_ratio = current_speed / max_speed
	var turn_multiplier = 1.0 - speed_ratio
	var new_dir = current_dir.slerp(target_dir, turn_rate * delta)
	
	

	# Apply Velocity
	body.velocity.x = new_dir.x * current_speed
	body.velocity.y = new_dir.y * current_speed
	body.velocity.z = 0
	
	body.move_and_slide()
	
	# Rotate to match new direction
	var angle = new_dir.angle()
	body.rotation.z = angle + 3*PI/2
	
	# Collision Check
	if body.get_last_slide_collision() != null:
		transitioned.emit(self, "missiledetonate")
		print("Boom")
