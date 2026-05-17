extends State
class_name PlayerCrouch

var actor: CharacterBody3D
var input_component: InputComponent
var crouchCollision: Area3D

##Used to adjust size of player collision and hurtbox while crouching
var playerCollision
var playerHurtbox
var shapeSize
var shapePos

signal overlap

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	input_component = blackboard["input_component"]
	
	crouchCollision = $"../../PlayerCrouchCollision"
	
	playerCollision = $"../../PlayerCollision"
	playerHurtbox = $"../../HurtboxComponent/CollisionShape3D"
	shapeSize = playerCollision.shape.size
	shapePos = playerCollision.position

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

func _process(delta: float) -> void:
	if crouchCollision.has_overlapping_bodies():
		_isCrouching()
		overlap.emit()


func physics_update(_delta: float) -> void:
	var input_state = input_component.get_input_state()
	
	# Add the gravity.
	if not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * _delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: float = input_state["movement"]
	var direction := (actor.transform.basis * Vector3(input_dir, 0, 0)).normalized()
	var speed = actor.crouch_speed * actor.speed_multiplier
	if direction:
		actor.velocity.x = direction.x * speed
	else:
		actor.velocity.x = move_toward(actor.velocity.x, 0, speed)
	
	actor.move_and_slide()

func _isCrouching():
	playerCollision.shape.size = Vector3(shapeSize.x, 2.4, shapeSize.z)
	playerCollision.position = Vector3(shapePos.x, shapePos.y - 0.4, shapePos.z)
	playerHurtbox.shape.size = Vector3(shapeSize.x, 2.4, shapeSize.z)
	playerHurtbox.position = Vector3(shapePos.x, shapePos.y - 0.4, shapePos.z)

func _isStanding():
	playerCollision.shape.size = shapeSize
	playerCollision.position = shapePos
	playerHurtbox.shape.size = shapeSize
	playerHurtbox.position = shapePos

func _on_player_input_crouching() -> void:
	_isCrouching()

func _on_player_input_standing() -> void:
	_isStanding()
	
