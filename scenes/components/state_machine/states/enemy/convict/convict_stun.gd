# Stun State: Convict freezes for a second after being hit
#    TODO: add stun dialogue???

# Stun moves Chase

extends State

@export var failsafe_max_stun_duration: float = 8

var actor: CharacterBody3D
var anim: AnimationPlayer
var slow_down_speed: float
var total_stun_time: float
var stun_timer: float = 0.0

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	slow_down_speed = blackboard["slow_down_speed"]

func enter() -> void:
	pass

func update(_delta: float) -> void:
	stun_timer += _delta
	if stun_timer >= total_stun_time or stun_timer >= failsafe_max_stun_duration:
		transitioned.emit(self, "convictchase")

func physics_update(_delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * _delta)
	anim.play("Idle")
	actor.move_and_slide()
