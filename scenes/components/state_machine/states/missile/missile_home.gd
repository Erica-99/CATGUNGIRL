extends State
class_name MissileHomeIn

@export var speed := 20.0
@export var turn_rate := 6.0

var body
var player

func enter():
	body = blackboard["actor"]
	player = blackboard["player"]

func physics_update(delta):
	if not is_instance_valid(player):
		return

	# --- Positions (XY only) ---
	var target_pos = player.global_position
	var my_pos = body.global_position

	var desired = Vector2(
		target_pos.x - my_pos.x,
		target_pos.y - my_pos.y
	)

	# Prevent NaN if player is exactly on top of missile
	if desired.length() < 0.001:
		return

	desired = desired.normalized()

	# --- Current direction ---
	var current = Vector2(body.velocity.x, body.velocity.y)
	if current.length() < 0.001:
		current = desired
	else:
		current = current.normalized()

	# --- Smooth steering ---
	var new_dir = current.slerp(desired, turn_rate * delta)

	# --- Apply velocity ---
	body.velocity.x = new_dir.x * speed
	body.velocity.y = new_dir.y * speed
	body.velocity.z = 0

	body.move_and_slide()

	# --- Safe rotation ---
	var angle = new_dir.angle()

	if not is_nan(angle):
		body.rotation = Vector3(0, 0, angle)
