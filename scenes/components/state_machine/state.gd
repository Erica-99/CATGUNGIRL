extends Node
class_name State

@warning_ignore("unused_signal")
signal transitioned

var blackboard : Dictionary

func init(blackboard_dict : Dictionary) -> void:
	blackboard = blackboard_dict


func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
