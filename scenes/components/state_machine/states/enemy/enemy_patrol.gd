extends State
class_name EnemyPatrol

var move: EnemyMove
var idle: EnemyIdle

func update(_delta: float) -> void:
	#switch back and forth betwween move and idle
	if child_state == EnemyMove and child_state.is_complete:
		set_state(idle)
	elif child_state.is_complete:
		set_state(move)
		pass
