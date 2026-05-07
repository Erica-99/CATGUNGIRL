## State
## Base class for all states in state machines.

extends Node
class_name State

@warning_ignore("unused_signal")
signal transitioned

var blackboard : Dictionary

# flag that denotes when a state is complete
var is_complete: bool

# states can use a state machine to manage child states
var machine: AltStateMachine = AltStateMachine.new()
#Property to access machine.current_state with state
var child_state:
	get:
		return machine.current_state

# set blackboard
func init(blackboard_dict : Dictionary) -> void:
	blackboard = blackboard_dict
	
# functions for states to override
func enter() -> void:
	pass
func exit() -> void:
	pass
func update(_delta: float) -> void:
	pass
func physics_update(_delta: float) -> void:
	pass
