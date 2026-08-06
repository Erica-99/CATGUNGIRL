extends State
class_name PlayerJump

@export var gravity_multiplier: float

var actor: CharacterBody3D
var input_component: InputComponent

var jump_vel: float
var jump_velocity_applied := false
@export var jump_cut_multiplier: float = 0.5
var jump_cut := false

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	input_component = blackboard["input_component"]

func enter() -> void:
	jump_velocity_applied = false
	jump_cut = false
	if blackboard["mantle_detector"] != null:
		blackboard["mantle_detector"].set_checking_enabled(true)
	jump_vel = actor.jump_velocity

func exit() -> void:
	jump_velocity_applied = false
	if blackboard["mantle_detector"] != null:
		blackboard["mantle_detector"].set_checking_enabled(false)

func update(_delta: float) -> void:
	var input_state = input_component.get_input_state()
	if input_state["dashing"] and blackboard["dash_timer"].is_stopped() and blackboard["can_air_dash"]:
		var input_dir: float = input_state["movement"]
		if input_dir != 0.0:
			blackboard["dash_dir"] = sign(input_dir)
		else:
			blackboard["dash_dir"] = actor.facing
		transitioned.emit(self, "playerdash")
	elif (input_state["ability_held"] and blackboard["gun_holder"].current_gun.ability and 
	blackboard["gun_holder"].current_gun.ability.is_ability_enterable()):
		transitioned.emit(self, "playerability")
	elif actor.is_on_floor():
		if actor.velocity.x == 0:
			transitioned.emit(self, "playeridle")
		else:
			transitioned.emit(self, "playermove")
	elif actor.velocity.y < 0:
		transitioned.emit(self, "playerfall")

func physics_update(_delta: float) -> void:
	var input_state = input_component.get_input_state()
	
	if not jump_velocity_applied:
		actor.velocity.y = jump_vel
		jump_velocity_applied = true
		
	# cut jump short
	if !input_state["jumping"] and actor.velocity.y > 0.0 and !jump_cut:
		actor.velocity.y *= jump_cut_multiplier
		jump_cut = true
	
	# Add gravity
	if not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * _delta * gravity_multiplier
	
	# Add air movement
	var input_dir: float = input_state["movement"]
	var direction := (actor.transform.basis * Vector3(input_dir, 0, 0)).normalized()
	var speed = actor.air_speed
	var accel = actor.air_acceleration
	
	actor.velocity.x = clampf(actor.velocity.x + direction.x * accel * _delta, -speed, speed)
	
	actor.move_and_slide()
	
	var wall_jump_dir: float = actor.get_wall_jump_dir(input_dir)

	if wall_jump_dir != 0.0:
		blackboard["wall_jump_dir"] = wall_jump_dir
		transitioned.emit(self, "playerwallslide")
		return
	
	# Only allow mantle if player is pressing forward and can mantle.
	if input_state["movement"] != 0 and blackboard["mantle_detector"].can_mantle:
		blackboard["current_mantle_target"] = blackboard["mantle_detector"].get_target_mantle_point()
		transitioned.emit(self, "playermantle")


func _on_player_input_anti_bhop() -> void:
	#actor.jump_velocity *= 0.75
	pass # Replace with function body.
