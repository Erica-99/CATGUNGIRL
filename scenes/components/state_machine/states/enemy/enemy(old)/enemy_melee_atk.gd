extends State
class_name EnemyMeleeAtk

@onready var sprite_anims = $"../../../Visuals/AnimationPlayer"

@export var hitbox: Area3D
@export var atk_check: Area3D
@export var animation = ''

func _ready() -> void:
	hitbox.monitoring = false
	hitbox.monitorable = false

func enter() -> void:
	
	
	# Diable monitoring
	hitbox.monitoring = false
	hitbox.monitorable = false
	
	# Play Attack Animation
	sprite_anims.play(animation)
	
	
	pass

func update(_delta: float) -> void:
	if sprite_anims.is_playing() == false:
		complete("Melee Finished")



func enable_hitbox():
	hitbox.monitoring = true
	hitbox.monitorable = true

func disable_hitbox():
	hitbox.monitoring = false
	hitbox.monitorable = false
	print("Enemy Swung")

func attack_opp() -> bool:
	#if player in range and 
	if atk_check.player_detected:
		return true
	else:
		return false
