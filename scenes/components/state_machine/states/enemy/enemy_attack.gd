extends State
class_name EnemyAttack

@export var attack_cooldown: float
@export var attack_check: Area3D

var cooldown_timer: float
var player_in_range: bool = false

var animator: AnimatedSprite3D

@export var attack_duration: float

var attack_timer: float


func enter() -> void:
	# Play animation (changes color for test)
	animator = blackboard["anim"]
	animator.modulate = Color(0.8, 0.6, 0.02, 1.0)

func _process(delta: float) -> void:
	cooldown_timer += delta
	
func update(_delta: float) -> void:
	attack_timer += _delta
	if attack_timer >= attack_duration:
		is_complete = true

func attack_opp() -> bool:
	#if player in range and 
	if cooldown_timer >= attack_cooldown and attack_check.player_detected:
		return true
	else:
		return false
