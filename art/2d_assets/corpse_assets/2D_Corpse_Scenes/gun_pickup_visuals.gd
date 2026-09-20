extends Node3D

@export var sprite: AnimatedSprite3D
@export var held_gun_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.unlock_gun.connect(_remove_gun_from_hands)
	pass # Replace with function body.

func _remove_gun_from_hands(gun_name: String) -> void:
	if gun_name == held_gun_name:
		sprite.play("empty")
