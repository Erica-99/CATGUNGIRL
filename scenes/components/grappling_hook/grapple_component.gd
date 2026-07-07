extends Node3D

@export var grapple_raycast: RayCast3D
@export var grapple_hook_scene: PackedScene
@export var actor: CharacterBody3D

@export_group("Grapple Attributes")
@export var fire_speed: float = 10
@export var reel_delay: float = 0.5
@export var reel_force: float = 10

var state_machine: StateMachine

var blackboard: Dictionary = {
	"actor": actor,
	"grapple_hook_scene": grapple_hook_scene,
	"current_grapple_hook": null,
	"grapplegun_object": self,
	"fired_position": position,
	"target_position": position,
	"grapple_raycast": grapple_raycast,
	"fire_speed": fire_speed,
	"reel_delay": reel_delay,
	"reel_force": reel_force
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_machine = $StateMachine
	state_machine.init(blackboard)
