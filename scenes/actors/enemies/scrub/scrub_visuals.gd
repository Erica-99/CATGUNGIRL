extends Node3D
@onready var scrubroot: CharacterBody3D = $".."
@onready var head_p: Node3D = $Visual_MOVE_P/Torso_P/Head_P
@onready var torso_p: Node3D = $Visual_MOVE_P/Torso_P
@onready var legs_p: Node3D = $Visual_MOVE_P/Torso_P/Legs_P
@onready var gun_aim_p: Node3D = $Visual_MOVE_P/Torso_P/Gun_P/Gun_AIM_P
@onready var scrub_gun: Node3D = $"../ScrubGun"
#@onready var scrub_gun: Node3D = $Visual_MOVE_P/Torso_P/Gun_P/Gun_AIM_P/ScrubGun
@onready var gun_sprite: AnimatedSprite3D = $Visual_MOVE_P/Torso_P/Gun_P/Gun_AIM_P/AnimatedSprite3D

var facing_direction: float = 1

func _process(delta: float) -> void:
	gun_aim_p.rotation.z = scrub_gun.rotation.z * facing_direction
	#print(scrub_gun.rotation)
	#print(gun_aim_p.rotation)
	#print(facing_direction)

func _on_scrub_facing_changed(scrub: CharacterBody3D) -> void:
	facing_direction = scrub.facing
	if scrub.facing == -1.0:
		#legs_p.scale.x = -1
		torso_p.scale.x = -0.59
		gun_sprite.flip_h = false
		#gun_aim_p.scale.x = -1
		gun_aim_p.scale.y = -1
		scrub_gun.position
	else:
		#legs_p.scale.x = 1
		torso_p.scale.x = 0.59
		gun_sprite.flip_h = true
		#gun_aim_p.scale.x = 1
		gun_aim_p.scale.y = 1

	scrub_gun.position.x *= -1
