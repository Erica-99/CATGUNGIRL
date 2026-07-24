extends Node3D
class_name Ability

var _ability_state: State
var _actor_blackboard: Dictionary
var active: bool = false:
	set(value):
		active = value
		visible = active
		_set_children_active(active)

# Override this method if you need the state to only be enterable with certain conditions.
func is_ability_enterable() -> bool:
	return true

func initialise(ability_state: State, actor_blackboard: Dictionary) -> void:
	_ability_state = ability_state
	_actor_blackboard = actor_blackboard
	
func _end_ability() -> void:
	_ability_state.emit_signal("end_ability")

func _set_children_active(_active: bool) -> void:
	if not _active:
		for child in get_children():
			child.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		for child in get_children():
			child.process_mode = Node.PROCESS_MODE_INHERIT
