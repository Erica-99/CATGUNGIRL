extends Ability
class_name GrappleComponent

signal cancel_hook

@export var grapple_raycast: RayCast3D
@export var grapple_hook_scene: PackedScene
@export var retract_state: State
var actor: CharacterBody3D

@export_group("Grapple Attributes")
@export var total_fire_time: float = 1
@export var firing_curve: Curve
@export var reel_delay: float = 0.5
@export var reel_force: float = 10
@export var reel_minimum_distance: float = 2

var state_machine: StateMachine
var blackboard: Dictionary = {}

func _ready() -> void:
	cancel_hook.connect(on_cancel_hook)


func initialise(ability_state: State, actor_blackboard: Dictionary) -> void:
	super.initialise(ability_state, actor_blackboard)
	
	actor = actor_blackboard["actor"]
	
	blackboard = {
		"actor": actor,
		"actor_blackboard": actor_blackboard, # Mostly needed to pass through the input component
		"grapple_hook_scene": grapple_hook_scene,
		"current_grapple_hook": null,
		"grapplegun_object": self,
		"fired_position": position,
		"target_position": position,
		"grapple_raycast": grapple_raycast,
		"total_fire_time": total_fire_time,
		"firing_curve": firing_curve,
		"reel_delay": reel_delay,
		"reel_force": reel_force,
		"reel_min_dist": reel_minimum_distance,
		"rope_attach_point": actor_blackboard["gun_component"].muzzle
	}
	
	state_machine = $StateMachine
	state_machine.init(blackboard)
	retract_state.primed = true

func on_cancel_hook() -> void:
	if blackboard["current_grapple_hook"] != null:
		blackboard["current_grapple_hook"].queue_free()
		blackboard["current_grapple_hook"] = null
	
	_ability_state.end_ability.emit()
