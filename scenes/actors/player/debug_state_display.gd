extends Label3D


func _on_movement_state_machine_state_changed(_prev: String, new: String) -> void:
	text = new
