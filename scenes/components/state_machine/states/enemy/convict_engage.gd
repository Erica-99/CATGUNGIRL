extends State
class_name  ConvictEngage

@export var alert: EnemyAlert
@export var move: EnemyMove
@export var fwd_attack: EnemyMeleeAtk
@export var idle: EnemyIdle

@export var sight_area: Area3D
@export var abandon_time: float
@export var attack_cooldown: float

var abandon_timer: float
var cooldown_timer: float

func enter() -> void:
	# Reset abanddon timer
	abandon_timer = 0
	cooldown_timer = attack_cooldown

	# Enter alert by default
	set_state(alert)

func update(_delta: float) -> void:
	# Tick up abandon_timer
	abandon_timer += _delta
	
	if child_state is EnemyMeleeAtk == false:
		cooldown_timer += _delta
	
	# Resets timer if player_spotted
	if player_spotted(): 
		abandon_timer = 0
	
	move.destination = sight_area.target_pos # Adjusts destination if player has moved
	
	
	if abandon_timer >= abandon_time: # If player out of sight for abandon_time, give up chase
		is_complete = true
	
	if child_state is EnemyAlert:
		if child_state.is_complete:
			if fwd_attack.attack_opp():
				set_state(fwd_attack)
			else:
				set_state(move)
	elif fwd_attack.attack_opp() and cooldown_timer >= attack_cooldown:
		cooldown_timer = 0
		set_state(fwd_attack)
	elif child_state is EnemyMeleeAtk and child_state.is_complete:
		set_state(idle)
	elif child_state is EnemyIdle and child_state.is_complete:
		set_state(move)
	elif child_state is EnemyMove and child_state.is_complete:
		is_complete = true


# Used by parent to determine when to enter, and reset abandon_timer if player is still in sight
func player_spotted() -> bool:
	if sight_area.player_detected:
		return true
	else:
		return false
