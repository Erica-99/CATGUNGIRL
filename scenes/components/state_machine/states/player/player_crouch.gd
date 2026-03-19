extends State
class_name PlayerCrouch

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
	var input_state = input_component.get_input_state()
	
	if input_state["jumping"]:
		transitioned.emit(self, "playerjump")
	elif not input_state["crouching"]:
		if input_state["movement"]:
			transitioned.emit(self, "playermove")
		else:
			transitioned.emit(self, "playeridle")

func physics_update(_delta: float) -> void:
	var input_state = input_component.get_input_state()
	
	# Add the gravity.
	if not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * _delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: float = input_state["movement"]
	var direction := (actor.transform.basis * Vector3(input_dir, 0, 0)).normalized()
	var speed = blackboard['crouch_speed']
	if direction:
		actor.velocity.x = direction.x * speed
		actor.velocity.z = direction.z * speed
	else:
		actor.velocity.x = move_toward(actor.velocity.x, 0, speed)
		actor.velocity.z = move_toward(actor.velocity.z, 0, speed)
	
	# Handle jump.
	if input_state["jumping"] and actor.is_on_floor():
		actor.velocity.y = actor.JUMP_VELOCITY
