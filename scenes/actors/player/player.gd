extends CharacterBody3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

@export var movement_state_machine: StateMachine
@export var input_component: InputComponent

var blackboard: Dictionary

func _ready() -> void:
	blackboard = {
	"actor": self,
	"movespeed" : SPEED,
	"input_component": input_component,
	}
	
	movement_state_machine.init(blackboard)
