extends Node3D

class_name BaseGun

@export var team_component: Node		# player TeamComponent reference, passed to bullets

@export_category("General Aim and Recoil")
@export var aim_settled_threshold: float = 98.0		# % of recoil recovered
@export var recoil_amount: float = 0.35		# higher = more

# general all-team variables
var _is_spamming: bool = false
var _spam_count: int = 0			# track spam count
var _recoil_offset: float = 0.0 
var _time_since_last_shot: float = 999.0
var _current_target_angle: float = 0.0	# stores current target angle for perfect shot detection

# _target is enemy-only variable
var _target: CharacterBody3D

signal bullet_fired()
signal enemy_hit(damage: float)

func _ready() -> void:
	randomize()
	if team_component.team == Enums.Team.PLAYER:
		pass
	else:
		_target = get_tree().get_first_node_in_group("player") as CharacterBody3D

# check if aim within threshold
func _is_aim_settled() -> bool:
	return abs(_recoil_offset) < recoil_amount * (1.0 - aim_settled_threshold / 100.0)
