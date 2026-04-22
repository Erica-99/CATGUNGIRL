extends Node3D

@onready var spriteanimator = $ROOT_P/FullBody_Anims

@onready var legs_sprite = $ROOT_P/BODY_P/LEG_P/LEGS_SPRITE
@onready var torso_sprite = $ROOT_P/BODY_P/TORSO_P/TORSO_SPRITE
@onready var hand_sprite = $ROOT_P/GUN_P/GUN_AIM/GUN_SPRITE

@onready var torso_pivot = $ROOT_P/BODY_P/TORSO_P
@onready var leg_pivot = $ROOT_P/BODY_P/LEG_P

@onready var hand_pivot = $ROOT_P/GUN_P
@onready var gun_pivot = $ROOT_P/GUN_P/GUN_AIM
@onready var gun_component = $"../GunComponent"

@onready var Playeroot = $".."
var current_action 


func _process(delta: float) -> void:
		
	gun_pivot.rotation.z = gun_component.rotation.z
	if current_action == 'playercrouch':
		if Input.is_action_pressed("move_left") == true or Input.is_action_pressed("move_right") == true:
			spriteanimator.play("Walk_Crouching")
		else:
			spriteanimator.play("Idle_Crouch")
		pass

func _on_movement_state_machine_state_changed(_prev: String, new: String) -> void:
	current_action = new
	print(new)
	spriteanimator.play("RESET")
	if new == 'playermove':
		spriteanimator.play("Running_Standing")
		pass
	elif new == 'playeridle':
		spriteanimator.play("Idle_Standing")
		pass
	elif new == 'playerjump':
		spriteanimator.play("Jump")
		pass
	elif new == 'playerfall':
		spriteanimator.play("Fall")
		pass
	elif new == 'playercrouch':
		
		pass


func _on_player_facing_changed(new_facing: float) -> void:
	print(new_facing)
	if new_facing == -1.0:
		leg_pivot.scale.x = -1
		torso_pivot.scale.x = -1
		gun_pivot.scale.x = 1
		gun_pivot.scale.y = -1
	else:
		leg_pivot.scale.x = 1
		torso_pivot.scale.x = 1
		gun_pivot.scale.x = 1
		gun_pivot.scale.y = 1
	pass # Replace with function body.
