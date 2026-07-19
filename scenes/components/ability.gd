extends Node3D
class_name Ability

var _ability_state: State
var _actor_blackboard: Dictionary

func initialise(ability_state: State, actor_blackboard: Dictionary) -> void:
	_ability_state = ability_state
	_actor_blackboard = actor_blackboard
	
func _end_ability() -> void:
	_ability_state.emit_signal("end_ability")
