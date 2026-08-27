## StateMachine
## Generic state machine class to be used anywhere a state machine is needed.
## States are added as nodes which inherit from the State class.

extends Node
class_name StateMachine

signal state_changed(prev: String, new: String)

@export var initial_state: State

@export_category("Debug")
@export var block_state_transitions: bool = true

var current_state : State
var current_state_name: String
var states : Dictionary = {}


func init(blackboard: Dictionary = {}) -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			if not child.transitioned.is_connected(on_child_transition):
				child.transitioned.connect(on_child_transition)
			child.init(blackboard)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta: float) -> void:
	_handle_debug_no_aggro()
	
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	_handle_debug_no_aggro()
	
	if current_state:
		current_state.physics_update(delta)

func on_child_transition(state: State, new_state_name: String):
	if state != current_state:
		return
	
	if block_state_transitions and DebugManager.no_aggro and !_debug_allowed_transition(new_state_name):
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	_change_state(new_state)


func _handle_debug_no_aggro() -> void:
	if !block_state_transitions:
		return
	
	if !DebugManager.no_aggro:
		return
	
	if initial_state == null:
		return
	
	if current_state == null:
		return
	
	if current_state == initial_state:
		return
	
	if _debug_allowed_transition(current_state.name):
		return
	
	_change_state(initial_state)

func _debug_allowed_transition(state_name: String) -> bool:
	return state_name.to_lower().contains("death")

func _change_state(new_state: State) -> void:
	var previous_state_name: String = ""
	
	if current_state:
		previous_state_name = current_state.name.to_lower()
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
	current_state_name = new_state.name.to_lower()
	
	state_changed.emit(previous_state_name, current_state_name)
