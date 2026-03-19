extends State
class_name PlayerIdle

var actor: CharacterBody3D
var input_component: InputComponent

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	input_component = blackboard["input_component"]

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	var current_input_state = input_component.get_input_state()
	
	if current_input_state["jumping"]:
		transitioned.emit(self, "playerjump")
	elif not actor.is_on_floor():
		transitioned.emit(self, "playerfall")
	elif current_input_state["crouching"]:
		transitioned.emit(self, "playercrouch")
	elif current_input_state["movement"]:
		transitioned.emit(self, "playermove")

func physics_update(_delta: float) -> void:
	pass
