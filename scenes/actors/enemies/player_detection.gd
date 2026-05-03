extends Area3D

var player_detected: bool = false
var player_ref: Node3D = null
var target_pos: Vector3

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

# On body enter, evaluates if player has entered collision area
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_detected = true
		player_ref = body

# On body exit, evaluates if player has left the collision area
func _on_body_exited(body):
	if body.is_in_group("player"):
		player_detected = false
		player_ref = null

# If player_detected is within collision area, updates position of target
func _physics_process(delta):
	if player_detected and player_ref:
		target_pos = player_ref.global_position
