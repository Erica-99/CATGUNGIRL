extends State
class_name PlayerWallJump

var actor: CharacterBody3D
var input_component: InputComponent

var wall_jump_dir: float = 0.0
var control_lock_timer: float = 0.0

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	input_component = blackboard["input_component"]
	
func enter() -> void:
	wall_jump_dir = blackboard.get("wall_jump_dir", 0.0)
	control_lock_timer = actor.wall_jump_control_lock_time
	
	actor.set_facing(wall_jump_dir)
	actor.velocity.x = wall_jump_dir * actor.wall_jump_horizontal_velocity
	actor.velocity.y = actor.wall_jump_vertical_velocity
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	var input_state = input_component.get_input_state()
	if actor.is_on_floor():
		if actor.velocity.x == 0:
			transitioned.emit(self, "playeridle")
		else:
			transitioned.emit(self, "playermove")
	elif (input_state["ability_held"] and blackboard["gun_holder"].current_gun.ability and 
	blackboard["gun_holder"].current_gun.ability.is_ability_enterable()):
		transitioned.emit(self, "playerability")
	elif actor.velocity.y < 0:
		transitioned.emit(self, "playerfall")
		
func physics_update(_delta: float) -> void:
	if not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * _delta
		
	if control_lock_timer > 0.0:
		control_lock_timer -= _delta
	else:
		var input_state = input_component.get_input_state()
		var input_dir: float = input_state["movement"]
		var direction := (actor.transform.basis * Vector3(input_dir, 0, 0)).normalized()
		
		actor.velocity.x += direction.x * actor.air_acceleration * _delta
		actor.velocity.x = clampf(actor.velocity.x, -actor.wall_jump_horizontal_velocity, actor.wall_jump_horizontal_velocity)
		
	actor.move_and_slide()
