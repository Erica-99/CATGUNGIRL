# Idle State: Scrub stands still, ready to detect player
#   In future: Play idle dialogue

# Before being alerted to the player, the Scrub will either:
#   - Stand in place
#   - Patrol a select area
# (Dependent on level design)

# From Idle State the Scrub can transition into:
#   - Patrol, move a short distance
#   - Alert, when player detected play a short Alert animation and move
#       to alert phase.

extends State
class_name SwitchScrubIdle

# Information gained from state machine
var actor: CharacterBody3D
var anim: AnimationPlayer
var slow_down_speed: float

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	slow_down_speed = blackboard["slow_down_speed"]
	

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	actor.velocity.x = move_toward(actor.velocity.x, 0, slow_down_speed * delta)
	#anim.play("idle")
	
	actor.move_and_slide()


func _on_detection_area_3d_body_entered(body: Node3D) -> void:
		if !actor.is_dead:
			actor.detected_player = true
			if actor.gun_switch_timer.is_stopped():
				actor.gun_switch_timer.start()
			if actor.in_attacking_range:
				transitioned.emit(self, "switchscrubattack")
			else:
				transitioned.emit(self, "switchscrubchase")


func _on_flee_area_3d_body_entered(body: Node3D) -> void:
	if !actor.is_dead:
		transitioned.emit(self, "switchscrubflee")
