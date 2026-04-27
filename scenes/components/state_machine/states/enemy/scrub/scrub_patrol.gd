# Patrol State: Scrub moves back and forth a set path, ready to detect player
#   In future: Play patrolling dialogue

# Before being alerted to the player, the Scrub will either:
#   - Stand in place
#   - Patrol a select area
# (Dependent on level design)

# From Patrol State the Scrub can transition into:
#   - Idle, stay still
#   - Alert, when player detected play a short Alert animation and move
#       to alert phase.

extends State
class_name ScrubPatrol

# Information gained from state machine
var actor: CharacterBody3D

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
