extends Node3D
@onready var scrubroot: CharacterBody3D = $".."
@onready var visual_p = $Visual_MOVE_P
@onready var head_p: Node3D = $Visual_MOVE_P/Torso_P/Head_P
@onready var torso_p: Node3D = $Visual_MOVE_P/Torso_P
@onready var legs_p: Node3D = $Visual_MOVE_P/Torso_P/Legs_P
#@onready var scrub_gun: Node3D = $"../ScrubGun"
@onready var base_gun: Node3D = scrubroot.gun_switcher
#@onready var scrub_gun: Node3D = $Visual_MOVE_P/Torso_P/Gun_P/Gun_AIM_P/ScrubGun

@export var gun_aim_p: Node3D
@export var gun_sprite: AnimatedSprite3D

var facing_direction: float = 1

func _ready() -> void:
	randomize()
	var spriteoffset = randi_range(0.0,0.5)
	position.z = spriteoffset
	
	if gun_aim_p == null or gun_sprite == null:
		print("ALERT: Aim node and/or gun sprite hasn't been assigned for a scrub!")

	
	#pass
	#print(scrub_gun.rotation)
	#print(gun_aim_p.rotation)
	#print(facing_direction)

func _on_scrub_facing_changed(scrub: CharacterBody3D) -> void:
	facing_direction = scrub.facing
	#scrub_gun._direction_change(facing_direction)
	if scrub.facing == -1.0:
		#legs_p.scale.x = -1
		visual_p.scale.x = -1
		gun_sprite.flip_h = false
		gun_aim_p.scale.x = -1
		gun_aim_p.scale.y = -1
		#scrub_gun.position
	else:
		#legs_p.scale.x = 1
		visual_p.scale.x = 1
		gun_sprite.flip_h = true
		gun_aim_p.scale.x = 1
		gun_aim_p.scale.y = 1

	base_gun.position.x *= -1
