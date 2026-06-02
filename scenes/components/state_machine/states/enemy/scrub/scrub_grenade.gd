# Grenade State: animation that pulls out a grenade and throws it at player

# TODECIDE: condition for grenade

# From Grenade State the Scrub can transition into:
#   - Attack, returns to shooting after grenade is thrown
#   - NOTE: Scrub is locked into the grnade animation, providing an
#       opening for the player.

extends State
class_name ScrubGrenade

# Information gained from state machine
var actor: CharacterBody3D

func init(blackboard_dict : Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
