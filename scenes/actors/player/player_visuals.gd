extends Node3D

@onready var spriteanimator = $ROOT_P/FULLBODY_ANIMS

@onready var legs_sprite = $ROOT_P/BODY_P/LEG_P/LEGS_SPRITE
@onready var torso_sprite = $ROOT_P/BODY_P/TORSO_P/TORSO_SPRITE

@onready var torso_pivot = $ROOT_P/BODY_P/TORSO_P

func _on_movement_state_machine_state_changed(_prev: String, new: String) -> void:
	spriteanimator.play("RESET")
	if new == 'playermove':
		spriteanimator.play("Running")
	else:
		spriteanimator.play("Idle")


func _on_player_facing_changed(new_facing: float) -> void:
	print(new_facing)
	if new_facing == -1.0:
		legs_sprite.flip_h = true
		torso_pivot.scale.x = -1
	else:
		legs_sprite.flip_h = false
		torso_pivot.scale.x = 1
	pass # Replace with function body.
