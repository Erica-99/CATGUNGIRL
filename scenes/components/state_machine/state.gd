## State
## Base class for all states in state machines.

extends Node
class_name State

@warning_ignore("unused_signal")
signal transitioned

var blackboard : Dictionary

func init(blackboard_dict : Dictionary) -> void:
	blackboard = blackboard_dict

## Use to set new animations etc.
func enter() -> void:
	pass

## Clean up any leftover variables like airtime, resources, etc.
func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
