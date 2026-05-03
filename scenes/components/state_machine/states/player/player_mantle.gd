extends State
class_name PlayerMantle

@export var mantle_time:float = 0.5

var actor: CharacterBody3D
var input_component: InputComponent

var current_mantle_target: Vector3
var mantle_target_corrected: Vector3
var lerp_progress: float
var starting_position: Vector3

var original_collision_mask: int

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	input_component = blackboard["input_component"]

func enter() -> void:
	current_mantle_target = blackboard["current_mantle_target"]
	mantle_target_corrected = current_mantle_target - blackboard["feet_point"].position
	lerp_progress = 0
	starting_position = actor.global_position
	actor.velocity = Vector3.ZERO
	original_collision_mask = actor.collision_mask
	actor.collision_mask = 0

func exit() -> void:
	lerp_progress = 0
	actor.collision_mask = original_collision_mask

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	if lerp_progress < 1.0:
		var pos_to_move_to = lerp(starting_position, mantle_target_corrected, lerp_progress)
		actor.global_position = pos_to_move_to
		actor.move_and_slide()
		lerp_progress += _delta / mantle_time
	else:
		actor.global_position = mantle_target_corrected
		actor.move_and_slide()
		transitioned.emit(self, "playeridle")
