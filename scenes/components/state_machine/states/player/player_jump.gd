extends State
class_name PlayerJump

@export var gravity_multiplier: float

var actor: CharacterBody3D
var input_component: InputComponent

var jump_velocity_applied := false

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	input_component = blackboard["input_component"]

func enter() -> void:
	jump_velocity_applied = false

func exit() -> void:
	jump_velocity_applied = false

func update(_delta: float) -> void:
	if actor.is_on_floor():
		if actor.velocity.x == 0:
			transitioned.emit(self, "playeridle")
		else:
			transitioned.emit(self, "playermove")
	elif actor.velocity.y < 0:
		transitioned.emit(self, "playerfall")

func physics_update(_delta: float) -> void:
	
	if not jump_velocity_applied:
		actor.velocity.y = actor.JUMP_VELOCITY
		jump_velocity_applied = true
	
	# Add gravity
	if not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * _delta * gravity_multiplier
	
	actor.move_and_slide()
