extends Area3D

var player_detected: bool
var target_pos: Vector3

# Gets all bodies in collision shape and checks if they are in the "player" group
func _physics_process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	for b in bodies:
		if b.is_in_group("player"):
			player_detected = true
			target_pos = b.position
