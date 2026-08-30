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
class_name ScrubIdle

# Information gained from state machine
var actor: CharacterBody3D
var anim: AnimatedSprite3D
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
			if actor.in_attacking_range:
				transitioned.emit(self, "scrubattack")
			else:
				transitioned.emit(self, "scrubchase")


func _on_flee_area_3d_body_entered(body: Node3D) -> void:
	if !actor.is_dead:
		transitioned.emit(self, "scrubflee")
