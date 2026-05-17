extends State
class_name PlayerMove

var actor: CharacterBody3D
var input_component: InputComponent

var direction_last_frame: Vector3

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard['actor']
	input_component = blackboard['input_component']

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	var input_state = input_component.get_input_state()
	if input_state["jumping"] and blackboard.get("jump_timer").is_stopped():
		transitioned.emit(self, "playerjump")
	elif not actor.is_on_floor():
		transitioned.emit(self, "playerfall")
	elif input_state["crouching"]:
		transitioned.emit(self, "playercrouch")
	elif actor.velocity.x == 0:
		transitioned.emit(self, "playeridle")


func physics_update(_delta: float) -> void:
	var input_state = input_component.get_input_state()
	# Right now this is all just using the provided godot sample code for movement so I can test. This will be completely changed.
	# Handling inputs inside states is a horrible idea.
	
	# Add the gravity.
	if not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * _delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: float = input_state["movement"]
	var direction := (actor.transform.basis * Vector3(input_dir, 0, 0)).normalized()
	var speed = actor.speed * actor.speed_multiplier
	var accel = actor.acceleration
	
	if direction and direction == direction_last_frame:
		actor.velocity.x = clampf(actor.velocity.x + direction.x * accel * _delta, -speed, speed)
	else:
		actor.velocity.x = move_toward(actor.velocity.x, 0, speed)
	
	direction_last_frame = direction
	
	actor.move_and_slide()


func _on_player_crouch_overlap() -> void:
	transitioned.emit(self, "playercrouch")
