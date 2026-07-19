extends State
class_name GrappleRetracted


func enter() -> void:
	pass
func exit() -> void:
	pass
func update(_delta: float) -> void:
	var input_state = blackboard["actor_blackboard"]["input_component"].get_input_state()
	if input_state["ability_held"]:
		transitioned.emit(self, "GrappleShooting")
	
func physics_update(_delta: float) -> void:
	pass
