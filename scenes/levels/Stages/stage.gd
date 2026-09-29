extends Node3D

@export var music_ref: String

func _ready() -> void:
	AudioManager.play_music(music_ref)
