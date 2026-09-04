@abstract
extends Resource
class_name CallableSFX

@export var sfx_ref: String # Identifies desired SFX to call
@export var fallback_ref: String

@abstract func get_sfx() -> SoundEffect

func get_fallback_ref() -> String:
	return fallback_ref
