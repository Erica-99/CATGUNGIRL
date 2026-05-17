extends State
class_name PlayerJump

@export var gravity_multiplier: float

var actor: CharacterBody3D
var input_component: InputComponent

var jump_velocity_applied := false

var superJump = false

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	input_component = blackboard["input_component"]

func enter() -> void:

	jump_velocity_applied = false
	if blackboard["mantle_detector"] != null:
		blackboard["mantle_detector"].set_checking_enabled(true)

func exit() -> void:
	jump_velocity_applied = false
	if blackboard["mantle_detector"] != null:
		blackboard["mantle_detector"].set_checking_enabled(false)

func update(_delta: float) -> void:
	if actor.is_on_floor():
		if actor.velocity.x == 0:
			transitioned.emit(self, "playeridle")
		else:
			transitioned.emit(self, "playermove")
	elif actor.velocity.y < 0:
		transitioned.emit(self, "playerfall")

func physics_update(_delta: float) -> void:
	if blackboard["jump_timer"].is_stopped():
		if not jump_velocity_applied:
			actor.velocity.y = actor.jump_velocity
			jump_velocity_applied = true
		
	# Add gravity
	if not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * _delta * gravity_multiplier
	
	# Add air movement
	var input_state = input_component.get_input_state()
	var input_dir: float = input_state["movement"]
	var direction := (actor.transform.basis * Vector3(input_dir, 0, 0)).normalized()
	var speed = actor.air_speed
	var accel = actor.air_acceleration
	
	actor.velocity.x = clampf(actor.velocity.x + direction.x * accel * _delta, -speed, speed)
	
	actor.move_and_slide()
	
	# Only allow mantle if player is pressing forward and can mantle.
	if input_state["movement"] != 0 and blackboard["mantle_detector"].can_mantle:
		blackboard["current_mantle_target"] = blackboard["mantle_detector"].get_target_mantle_point()
		transitioned.emit(self, "playermantle")

func _on_player_input_super_jump() -> void:
	if not superJump:
		superJump = true
		actor.jump_velocity *= 1.5

func _on_player_input_has_landed() -> void:
	if superJump:
		actor.jump_velocity /= 1.5
		superJump = false

func _on_player_input_anti_bhop() -> void:
	#actor.jump_velocity *= 0.75
	pass # Replace with function body.
