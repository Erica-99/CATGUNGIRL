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
# Scrub can either stay still or patrol before being alerted
var stay_idle: bool

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
