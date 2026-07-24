extends Node3D
@onready var animated_sprite_3d: AnimatedSprite3D = $Torso/AnimatedSprite3D
@onready var sprite_pivot = $Torso
@onready var platform_check: RayCast3D = $"../PlatformCheck"
@onready var object_check: RayCast3D = $"../ObjectCheck"
@onready var anim_manager = $TorsoAnims



# chuck all visual code stuff and gun/missile aiming here

func _on_trunk_facing_changed(trunk: CharacterBody3D) -> void:
	if trunk.facing == -1.0:
		#legs_p.scale.x = -1
		
		sprite_pivot.scale.x = -1
	else:
		sprite_pivot.scale.x = 1
	
	platform_check.target_position.x = -platform_check.target_position.x
	object_check.target_position.x = -object_check.target_position.x


func _on_state_machine_state_changed(prev: String, new: String) -> void:
	print(new)
	if new == 'TrunkIdle' or new == 'trunkoutranged':
		anim_manager.play("Idle")
	elif new == 'trunkchase':
		anim_manager.play('StepStart')
	pass # Replace with function body.


func _on_trunk_chase_reached_chase_offset(status: bool) -> void:
	if status:
		anim_manager.play("Idle")
	else:
		anim_manager.play("StepStart")


func _on_trunk_cant_step(status: bool) -> void:
	if status:
		anim_manager.play("Idle")
	else:
		anim_manager.play("StepStart")
