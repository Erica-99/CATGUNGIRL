extends State
class_name GrappleReeling

@export var reeling_animation_name: String

var reeling := false

var actor: CharacterBody3D
var hook: Node3D

var initial_dist: float

var cancelled_early: bool = false

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	
	actor = blackboard["actor"]

func enter() -> void:
	var delay = blackboard["reel_delay"]
	reeling = false
	hook = blackboard["current_grapple_hook"]
	hook.can_latch = false
	cancelled_early = false
	_enable_reeling_after_delay(delay)
	
func exit() -> void:
	blackboard["grapplegun_object"].cancel_hook.emit()
	
func update(_delta: float) -> void:
	if not blackboard["grapplegun_object"].active:
		cancelled_early = true
		transitioned.emit(self, "grappleretracted")
	
func physics_update(_delta: float) -> void:
	if not reeling:
		return
	
	var pull_direction = (hook.global_position - blackboard["rope_attach_point"].global_position).normalized()
	
	var pull_force = blackboard["reel_force"] * sqrt(initial_dist)
	
	actor.velocity = pull_direction * pull_force
	
	var input_state = blackboard["actor_blackboard"]["input_component"].get_input_state()
	if input_state["jumping"]:
		transitioned.emit(self, "grappleretracted")
	
	var dist = (actor.global_position - hook.global_position).length()
	if dist < blackboard["reel_min_dist"]:
		transitioned.emit(self, "grappleretracted")
	

func _enable_reeling_after_delay(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if not cancelled_early:
		initial_dist = (hook.global_position - blackboard["rope_attach_point"].global_position).length()
		actor.velocity = Vector3.ZERO
		reeling = true
		blackboard["grapplegun_object"].request_animation(reeling_animation_name)
	
	
