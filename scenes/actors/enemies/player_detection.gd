extends Area3D

var player_detected: bool
var target_pos: Vector3

func _physics_process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	for b in bodies:
		if b.is_in_group("player"):
			player_detected = true
			target_pos = b.position
