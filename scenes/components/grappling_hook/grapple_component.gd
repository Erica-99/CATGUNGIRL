extends Ability
class_name GrappleComponent

@export var grapple_raycast: RayCast3D
@export var grapple_hook_scene: PackedScene
@export var rope_attach_point: Marker3D
var actor: CharacterBody3D

@export_group("Grapple Attributes")
@export var total_fire_time: float = 1
@export var firing_curve: Curve
@export var reel_delay: float = 0.5
@export var reel_force: float = 10

var state_machine: StateMachine
var blackboard: Dictionary = {}

# Called when the node enters the scene tree for the first time.
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
		"rope_attach_point": rope_attach_point
	}
	
	state_machine = $StateMachine
	state_machine.init(blackboard)
