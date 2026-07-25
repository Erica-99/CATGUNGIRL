extends Node

func play_sfx(sfx_ref: String) -> void:
	AudioManager.play_sfx(sfx_ref)

func play_sfx_at_location(sfx_ref: String, location: Vector3) -> void:
	AudioManager.play_sfx_at_location(sfx_ref, location)
