extends Area3D
class_name GunSacrifice

var player = null

func _process(_delta: float) -> void:
	if player == null:
		return
	
	if !player.has_gun:
		return
	
	var input_state = player.input_component.get_input_state()
	
	if input_state.get("interacting", false):
		player.input_component._interacting = false
		player.sacrifice_current_gun()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body: Node3D) -> void:
	if body == player:
		player = null
