extends State
class_name EnemyChase

@export var alert: EnemyAlert
@export var move: EnemyMove
@export var abandon_time: float

var abandon_timer: float
var aggro: bool = false

func enter() -> void:
	set_state(move, true)
	abandon_timer = 0

func update(_delta: float) -> void:
	#Tick up abandon_timer
	abandon_timer += _delta
	
	# Resets timer if player_spotted
	if player_spotted():
		abandon_timer = 0
	
	# If not aggro (i.e. not already targeting player upon entering chase) activate alert state
	if aggro == false:
		aggro = true
		set_state(alert)
	elif child_state is EnemyAlert and child_state.is_complete:
		set_state(move)
	
	# If player out of sight for abandon_time, give up chase
	if abandon_timer >= abandon_time:
		aggro = false
		is_complete = true
	pass
	

# used by parent to determine when to enter, and reset abandon_timer if player is still in sight
func player_spotted() -> bool:
	#if player is in sight
	# returns true
	return false
	
	pass
