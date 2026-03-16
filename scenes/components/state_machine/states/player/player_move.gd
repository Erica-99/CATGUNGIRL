extends State
class_name PlayerMove

var actor: CharacterBody3D
var input_component: InputComponent

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard['actor']
	input_component = blackboard['input_component']
	input_component.input_signal.connect(_on_input_signal)


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	# Right now this is all just using the provided godot sample code for movement so i can test. This will be completely changed.
	# Handling inputs inside states is a horrible idea.
	
	# Add the gravity.
	if not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * _delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and actor.is_on_floor():
		actor.velocity.y = actor.JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_axis("ui_left", "ui_right")
	var direction := (actor.transform.basis * Vector3(input_dir, 0, 0)).normalized()
	var speed = blackboard['movespeed']
	if direction:
		actor.velocity.x = direction.x * speed
		actor.velocity.z = direction.z * speed
	else:
		actor.velocity.x = move_toward(actor.velocity.x, 0, speed)
		actor.velocity.z = move_toward(actor.velocity.z, 0, speed)

	actor.move_and_slide()

func _on_input_signal(_event: InputEvent):
	pass
