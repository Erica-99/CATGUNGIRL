extends Node3D

@export var sprite: AnimatedSprite3D
@export var held_gun_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.narrative_unlock_shotgun.connect(_remove_gun_from_hands)
	EventManager.narrative_unlock_sniper.connect(_remove_gun_from_hands)

func _remove_gun_from_hands() -> void:
	sprite.play("empty")
