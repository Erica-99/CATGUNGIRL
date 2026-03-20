extends CharacterBody3D

const SPEED: float = 15.0
const CROUCH_SPEED: float = 10.0
const JUMP_VELOCITY: float = 25

@export var movement_state_machine: StateMachine
@export var input_component: InputComponent

var blackboard: Dictionary

func _ready() -> void:
	blackboard = {
	"actor": self,
	"move_speed" : SPEED,
	"crouch_speed": CROUCH_SPEED,
	"input_component": input_component,
	}
	
	movement_state_machine.init(blackboard)
