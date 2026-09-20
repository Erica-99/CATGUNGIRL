extends Node3D

@onready var player = $"../../Player"

func _ready() -> void:
	look_at(player.global_position)
	pass

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
	pass # Replace with function body.
