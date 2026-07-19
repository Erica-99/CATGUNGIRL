extends State
class_name PlayerIdle

var actor: CharacterBody3D
var input_component: InputComponent

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	input_component = blackboard["input_component"]

func enter() -> void:
	blackboard["can_air_dash"] = true

func exit() -> void:
	pass

func update(_delta: float) -> void:
	var current_input_state = input_component.get_input_state()
	
	if current_input_state["dashing"] and blackboard["dash_timer"].is_stopped():
		var input_dir: float = current_input_state["movement"]	
		if input_dir != 0.0:
			blackboard["dash_dir"] = sign(input_dir)
		else:
			blackboard["dash_dir"] = actor.facing
		transitioned.emit(self, "playerdash")
	elif current_input_state["jumping"] and blackboard.get("jump_timer").is_stopped():
		transitioned.emit(self, "playerjump")
	elif current_input_state["ability_held"] and blackboard["equipped_ability"]:
		transitioned.emit(self, "playerability")
	elif not actor.is_on_floor():
		transitioned.emit(self, "playerfall")
	elif current_input_state["jumping"] and blackboard.get("jump_timer").is_stopped():
		transitioned.emit(self, "playerjump")
	elif current_input_state["crouching"]:
		transitioned.emit(self, "playercrouch")
	elif current_input_state["movement"]:
		var input_dir: float = current_input_state["movement"]
		var blocked_movement_dir: float = blackboard.get("blocked_movement_dir", 0.0)
		
		if sign(input_dir) == blocked_movement_dir:
			var test_direction := (actor.transform.basis * Vector3(input_dir, 0, 0)).normalized()
			var still_blocked := actor.test_move(actor.global_transform, test_direction * 0.2)
			
			if not still_blocked:
				blackboard["blocked_movement_dir"] = 0.0
				transitioned.emit(self, "playermove")
		else:
			transitioned.emit(self, "playermove")

func physics_update(_delta: float) -> void:
	actor.move_and_slide()

func _on_player_crouch_overlap() -> void:
	transitioned.emit(self, "playercrouch")
