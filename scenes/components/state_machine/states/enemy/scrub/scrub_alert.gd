# Alert State: upon detecting player, do a short Alerted animation
#   In future: Play alerted dialogue

# Scrub becomes alerted when player detected in Idle or Patrol
#   - Play alerted animation

# From Alert State the Scrub can transition into:
#   - Shoot, if player is in shooting range, shoot at them
#   - Flee, if player gets too close, try to run away
#   TODECIDE:
#   - Ready or Pursuit, if player gets out of attack range, either stay
#      still at the ready, or pursue to get into shooting range

extends State
class_name ScrubAlert

# Information gained from state machine
var actor: CharacterBody3D

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
