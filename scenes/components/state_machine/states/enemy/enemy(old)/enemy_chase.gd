extends State
class_name EnemyChase

@export var alert: EnemyAlert
@export var move: EnemyMove
@export var abandon_time: float
@export var sight_area: Area3D

var abandon_timer: float
var aggro: bool = false

func enter() -> void:
	# Reset abanddon timer
	abandon_timer = 0
	
	move.threshold = 0.1
	set_state(move)
	
	# If not aggro (i.e. not already targeting player upon entering chase) activate alert state
	if aggro == false:
		aggro = true
		set_state(alert)
	
func update(_delta: float) -> void:
	# Tick up abandon_timer
	abandon_timer += _delta
	
	# Resets timer if player_spotted
	if player_spotted(): 
		abandon_timer = 0
	
	move.destination = sight_area.target_pos # Adjusts destination if player has moved
	
	if child_state is EnemyAlert and child_state.is_complete: # Switch to move after Alert state has finished
		set_state(move)
	elif abandon_timer >= abandon_time: # If player out of sight for abandon_time, give up chase
		aggro = false
		is_complete = true

# Used by parent to determine when to enter, and reset abandon_timer if player is still in sight
func player_spotted() -> bool:
	if sight_area.player_detected:
		return true
	else:
		return false
