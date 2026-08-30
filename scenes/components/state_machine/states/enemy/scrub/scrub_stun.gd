# Stun State: Scrub stops in midair for a short time (will had floating down a bit soon)
#   In future: Play stun dialogue? Play stun animation?

# From Stun State the Scrub can transition into:
#   - Idle

extends State
class_name ScrubStun

@export var failsafe_max_stun_duration: float = 8
@export var att_range_area_3d: Area3D
@export var flee_area_3d: Area3D
#@onready var att_range_area_3d: Area3D = $AttRangeArea3D
#@onready var flee_area_3d: Area3D = $FleeArea3D

# Information gained from state machine
var actor: CharacterBody3D
var anim: AnimatedSprite3D
var slow_down_speed: float
var total_stun_time: float
var stun_timer: float = 0.0

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	slow_down_speed = blackboard["slow_down_speed"]

#func enter() -> void:
	#print("Stun Started")
	#print("Initial Total Stun Time = %f" %total_stun_time)

#func exit() -> void:
	#pass

func update(_delta: float) -> void:
	#print("In-Update Total Stun Time = %f" %total_stun_time)
	stun_timer += _delta
	#print("Stun Timer = %f" %stun_timer)
	if stun_timer >= total_stun_time or stun_timer >= failsafe_max_stun_duration:
		#print("Stun Finished: Pt 1")
		_go_to_next_state()
		#print("Stun Finished: Pt 1.5")

func physics_update(delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * delta)
	#anim.play("idle")
	actor.move_and_slide()

func _go_to_next_state():
	if len(flee_area_3d.get_overlapping_bodies()) != 0:
		#state_machine.on_child_transition(state_machine.current_state, "scrubflee")
		transitioned.emit(self, "scrubflee")
	elif len(att_range_area_3d.get_overlapping_bodies()) != 0:
		#state_machine.on_child_transition(state_machine.current_state, "scrubattack")
		transitioned.emit(self, "scrubattack")
	else:
		#state_machine.on_child_transition(state_machine.current_state, "scrubchase")
		transitioned.emit(self, "scrubchase")
