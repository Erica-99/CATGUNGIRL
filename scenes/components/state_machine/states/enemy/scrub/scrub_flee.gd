# Flee State: runs away from a close player

# From Flee State the Scrub can transition into:
#   - Attack, returns to shooting after done fleeing

extends State
class_name ScrubFlee

# Information gained from state machine
var actor: CharacterBody3D

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
