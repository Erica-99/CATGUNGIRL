extends State
class_name PlayerFall

@export var gravity_multiplier: float

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
	if actor.is_on_floor():
		if actor.velocity.x == 0:
			transitioned.emit(self, "playeridle")
		else:
			transitioned.emit(self, "playermove")

func physics_update(_delta: float) -> void:
	
	# Add gravity
	if not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * _delta * gravity_multiplier
	
	actor.move_and_slide()
