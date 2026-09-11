extends Node3D

@onready var anim = $AnimationPlayer

func _ready() -> void:
	anim.play("default")

func delete_self() -> void:
	queue_free()
