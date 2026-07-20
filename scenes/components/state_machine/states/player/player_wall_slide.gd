extends State
class_name PlayerWallSlide

var actor: CharacterBody3D
var input_component: InputComponent

var wall_jump_dir: float = 0.0
var jump_held_on_enter: bool = false

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	input_component = blackboard["input_component"]
	
func enter() -> void:
	wall_jump_dir = blackboard.get("wall_jump_dir", 0.0)
	blackboard["enable_facing_updates"] = false
	actor.set_facing(wall_jump_dir)
	
	var input_state = input_component.get_input_state()
	jump_held_on_enter = input_state["jumping"]
	
func exit() -> void:
	blackboard["enable_facing_updates"] = true
	
func update(_delta: float) -> void:
	var input_state = input_component.get_input_state()
	
	if actor.is_on_floor():
		if actor.velocity.x == 0:
			transitioned.emit(self, "playeridle")
		else:
			transitioned.emit(self, "playermove")
		return
	#stop instant wall jump when entering slide while holding jump
	if jump_held_on_enter and not input_state["jumping"]:
		jump_held_on_enter = false
	
	elif input_state["ability_held"] and blackboard["gun_holder"].current_gun.ability:
		transitioned.emit(self, "playerability")
		return

	if input_state["jumping"] and not jump_held_on_enter:
		transitioned.emit(self, "playerwalljump")
		return

	var input_dir: float = input_state["movement"]
	#exit wall slide if player presses away from wall
	if input_dir != 0.0 and sign(input_dir) == wall_jump_dir:
		transitioned.emit(self, "playerfall")
		return
	
func physics_update(_delta: float) -> void:
	if not actor.is_on_floor():
		actor.velocity += actor.get_gravity() * _delta
	#limit fall speed while sliding
	if actor.velocity.y < -actor.wall_slide_fall_speed:
		actor.velocity.y = -actor.wall_slide_fall_speed
	#push into wall slightly
	actor.velocity.x = -wall_jump_dir * actor.wall_slide_stick_velocity
	
	actor.move_and_slide()
	
	if not _is_still_touching_wall():
		transitioned.emit(self, "playerfall")
	
func _is_still_touching_wall() -> bool:
	for i in range(actor.get_slide_collision_count()):
		var collision = actor.get_slide_collision(i)
		var normal = collision.get_normal()

		if normal.x == 0.0:
			continue

		var is_too_steep := normal.angle_to(actor.up_direction) > actor.floor_max_angle
		#check if surface is valid wall
		var side_normal := Vector3(sign(normal.x), 0.0, 0.0)
		var is_valid_wall_angle := normal.angle_to(side_normal) <= deg_to_rad(actor.wall_slide_max_angle)

		if is_too_steep and is_valid_wall_angle and sign(normal.x) == wall_jump_dir:
			return true

	return false
