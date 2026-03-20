extends CharacterBody3D

signal facing_changed(new_facing: float)

const SPEED: float = 15.0
const CROUCH_SPEED: float = 10.0
const JUMP_VELOCITY: float = 25

var facing: float

@export var movement_state_machine: StateMachine

@export_group("Movement Dependencies")
@export var input_component: InputComponent
@export var mantle_detector: Node3D
@export var feet_point: Marker3D

var blackboard: Dictionary

func _ready() -> void:
	blackboard = {
	"actor": self,
	"move_speed" : SPEED,
	"crouch_speed": CROUCH_SPEED,
	"input_component": input_component,
	"mantle_detector": mantle_detector,
	"feet_point": feet_point,
	}
	
	movement_state_machine.init(blackboard)

func _process(delta: float) -> void:
	var current_state = input_component.get_input_state()
	
	if current_state["movement"] != 0:
		var new_direction = sign(current_state["movement"])
		if new_direction != facing:
			facing = new_direction
			facing_changed.emit(facing)
