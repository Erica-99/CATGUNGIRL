extends CharacterBody3D

class_name Missile

@export var state_machine: StateMachine

var blackboard: Dictionary

func _ready() -> void:
	blackboard = {
	"actor": self,
	"player": get_tree().get_first_node_in_group("player")
	}
	
	state_machine.init(blackboard)
