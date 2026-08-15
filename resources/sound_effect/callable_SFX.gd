@abstract
extends Resource
class_name CallableSFX

@export var sfx_ref: String # Identifies desired SFX to call

@abstract func get_sfx() -> SoundEffect
