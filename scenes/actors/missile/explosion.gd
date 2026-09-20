extends Node3D

@onready var anim = $AnimationPlayer

func _ready() -> void:
	anim.play("default")

func delete_self() -> void:
	queue_free()

func explode_sound() -> void:
	AudioManager.play_sfx_at_location("missile_explode", self.global_position)
