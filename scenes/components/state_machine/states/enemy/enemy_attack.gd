extends State
class_name EnemyAttack

@export var attack_cooldown: float

var cooldown_timer: float
var player_in_range: bool

func attack_opp() -> bool:
	#if player in range and 
	if cooldown_timer > attack_cooldown and player_in_range:
		return true
	else:
		return false
