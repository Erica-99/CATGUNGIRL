extends State
class_name GrappleRetracted


func enter() -> void:
	pass
func exit() -> void:
	pass
func update(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_grapplehook"):
		transitioned.emit(self, "GrappleShooting")
	
func physics_update(_delta: float) -> void:
	pass
