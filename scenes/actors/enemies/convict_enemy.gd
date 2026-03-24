extends CharacterBody3D

@export var state_machine: StateMachine

var blackboard : Dictionary = {
	"actor": self
	}

func _ready() -> void:
	state_machine.init(blackboard)
