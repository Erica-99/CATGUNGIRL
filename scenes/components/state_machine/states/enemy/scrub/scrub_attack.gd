# Attack State: stand still and shoot Player in attack range

# Attack after being Alerted

# From Attack State the Scrub can transition into:
#   - Grenade, after a set time/condition, the scrub will throw a grenade
#   - Flee, if player gets too close, try to run away
#   TODECIDE:
#   - Ready or Pursuit, if player gets out of attack range, either stay
#      still at the ready, or pursue to get into shooting range

extends State
class_name ScrubAttack

# Information gained from state machine
var actor: CharacterBody3D

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
