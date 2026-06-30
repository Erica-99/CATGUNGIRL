extends Node3D
@onready var player: CharacterBody3D = $".."

@onready var RosAnims = $ROOT_P/BODY_P/TORSO_P/Torso_Anims

#@onready var legs_sprite = $ROOT_P/BODY_P/LEG_P/LEGS_SPRITE
#@onready var torso_sprite = $ROOT_P/BODY_P/TORSO_P/TORSO_SPRITE
@onready var hand_sprite = $ROOT_P/GUN_P/GUN_AIM/Ros_Gun_Sprite
@onready var gun_anims = $ROOT_P/GUN_P/GUN_AIM/Hand_Anims

@onready var torso_pivot = $ROOT_P/BODY_P/TORSO_P
#@onready var leg_pivot = $ROOT_P/BODY_P/LEG_P

@onready var hand_pivot = $ROOT_P/GUN_P
@onready var gun_pivot = $ROOT_P/GUN_P/GUN_AIM
@onready var gun_component = player.current_gun

@onready var Playeroot = $".."
var current_action 


func _process(delta: float) -> void:
	gun_pivot.rotation.z = gun_component.rotation.z
	if current_action == 'playercrouch':
		if Input.is_action_pressed("move_left") == true or Input.is_action_pressed("move_right") == true:
			pass
		else:
			pass

func _on_movement_state_machine_state_changed(_prev: String, new: String) -> void:
	current_action = new
	if new == 'playermove':
		RosAnims.play("RunStand")
		pass
	elif new == 'playeridle':
		RosAnims.play("IdleStand")
		pass
	elif new == 'playerjump':
		RosAnims.play("Jump")
		pass
	elif new == 'playerfall':
		RosAnims.play("Fall")
		pass
	elif new == 'playercrouch':
		
		pass


func _on_player_facing_changed(new_facing: float) -> void:
	if new_facing == -1.0:
		torso_pivot.scale.x = -1
		gun_pivot.scale.x = 1
		gun_pivot.scale.y = -1
	else:
		torso_pivot.scale.x = 1
		gun_pivot.scale.x = 1
		gun_pivot.scale.y = 1
	pass # Replace with function body.


func _on_hand_anims_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Fire":
		gun_anims.play("Idle")
	pass # Replace with function body.
