extends Node3D

@onready var spriteanimator = $ROOT_P/FullBody_Anims

@onready var legs_sprite = $ROOT_P/BODY_P/LEG_P/LEGS_SPRITE
@onready var torso_sprite = $ROOT_P/BODY_P/TORSO_P/TORSO_SPRITE

@onready var torso_pivot = $ROOT_P/BODY_P/TORSO_P
@onready var leg_pivot = $ROOT_P/BODY_P/LEG_P

@onready var gun_pivot = $ROOT_P/BODY_P/TORSO_P/GUN_P/GUN_AIM
@onready var gun_component = $"../GunComponent"

func _process(delta: float) -> void:
	gun_pivot.rotation.z = gun_component.rotation.z
	if gun_pivot.rotation.z >= 90 or gun_pivot.rotation.z <= -90:
		pass

func _on_movement_state_machine_state_changed(_prev: String, new: String) -> void:
	print(new)
	spriteanimator.play("RESET")
	if new == 'playermove':
		spriteanimator.play("Running_Standing")
		pass
	elif new == 'playeridle':
		spriteanimator.play("Idle_Standing")
		pass
	elif new == 'playerjump':
		pass
	elif new == 'playerfall':
		pass
	elif new == 'playercrouch':
		spriteanimator.play("Idle_Crouch")
		pass


func _on_player_facing_changed(new_facing: float) -> void:
	if new_facing == -1.0:
		leg_pivot.scale.x = -1
		torso_pivot.scale.x = -1
	else:
		leg_pivot.scale.x = 1
		torso_pivot.scale.x = 1
	pass # Replace with function body.
