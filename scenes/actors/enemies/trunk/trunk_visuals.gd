extends Node3D
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var platform_check: RayCast3D = $"../PlatformCheck"
@onready var object_check: RayCast3D = $"../ObjectCheck"
# chuck all visual code stuff and gun/missile aiming here

func _on_trunk_facing_changed(trunk: CharacterBody3D) -> void:
	if trunk.facing == -1.0:
		#legs_p.scale.x = -1
		animated_sprite_3d.scale.x = -0.45
	else:
		animated_sprite_3d.scale.x = 0.45
	
	platform_check.target_position.x = -platform_check.target_position.x
	object_check.target_position.x = -object_check.target_position.x
