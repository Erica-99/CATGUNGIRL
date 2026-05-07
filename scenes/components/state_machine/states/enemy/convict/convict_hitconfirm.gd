# When Convict's attack hitbox collides with the target, they pause,
# do their attack anim, and their hitbox becomes inactive for a moment

extends State

signal attack_cd_finished()

var actor: CharacterBody3D
var anim: AnimatedSprite3D
var slow_down_speed: float
var attack_hitbox: Area3D

var cd_timer = 0
var attack_cd = 4

func init(blackboard_dict: Dictionary) -> void:
	super(blackboard_dict)
	actor = blackboard["actor"]
	anim = blackboard["anim"]
	slow_down_speed = blackboard["slow_down_speed"]
	attack_hitbox = blackboard["attack_hitbox"]

func enter() -> void:
	cd_timer = 0
	
func update(_delta: float) -> void:
	cd_timer += _delta
	if cd_timer > attack_cd:
		attack_cd_finished.emit()

func exit() -> void:
	cd_timer = 0
