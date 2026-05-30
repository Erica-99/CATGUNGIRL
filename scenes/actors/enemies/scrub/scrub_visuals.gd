extends Node3D
@onready var head_p: Node3D = $Visual_MOVE_P/Torso_P/Head_P
@onready var torso_p: Node3D = $Visual_MOVE_P/Torso_P
@onready var legs_p: Node3D = $Visual_MOVE_P/Torso_P/Legs_P
@onready var gun_aim_p: Node3D = $Visual_MOVE_P/Torso_P/Gun_P/Gun_AIM_P
@onready var scrub_gun: Node3D = $"../ScrubGun"
@onready var gun_sprite: AnimatedSprite3D = $Visual_MOVE_P/Torso_P/Gun_P/Gun_AIM_P/AnimatedSprite3D

var direction_addition: float = 0

func _process(delta: float) -> void:
	var aim_dir = Vector3(cos(scrub_gun.rotation.z), sin(scrub_gun.rotation.z), 0.0).normalized()
	var target_angle = Vector2(aim_dir.x, aim_dir.y).angle()
	gun_aim_p.rotation.z = target_angle + direction_addition

func _on_scrub_facing_changed(new_facing: float) -> void:
	if new_facing == -1.0:
		#legs_p.scale.x = -1
		torso_p.scale.x = -0.59
		direction_addition = PI
		#gun_sprite.flip_h = false
		#gun_aim_p.scale.x = -1
		#gun_aim_p.scale.y = -1
	else:
		#legs_p.scale.x = 1
		torso_p.scale.x = 0.59
		direction_addition = 0
		#gun_sprite.flip_h = true
		#gun_aim_p.scale.x = 1
		#gun_aim_p.scale.y = 1
