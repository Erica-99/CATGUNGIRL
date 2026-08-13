# Stun State: Trunk freezes for a second after being hit
#    TODO: add stun dialogue???

# Trunk moves Chase

extends State

class_name TrunkStun

@export var failsafe_max_stun_duration: float = 8

var actor: CharacterBody3D
var animation_manager: AnimationPlayer
var total_stun_time: float
var stun_timer: float = 0.0

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	animation_manager = blackboard["animation_manager"]

func enter() -> void:
	actor.step_handler.stop()
	animation_manager.play("Idle")

func exit() -> void:
	actor.step_handler.start()

func update(_delta: float) -> void:
	stun_timer += _delta
	if stun_timer >= total_stun_time or stun_timer >= failsafe_max_stun_duration:
		transitioned.emit(self, "trunkchase")
