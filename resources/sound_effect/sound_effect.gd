extends Resource
class_name SoundEffect

@export var sfx_ref: String
@export var sound_clip: AudioStreamMP3
@export_range(1, 10) var limit: int = 5
@export_range(-40, 20) var volume: float = 0
@export_range(0.01, 4.0, 0.01) var pitch_scale: float = 1
@export_range(0.0, 1.0, 0.01) var pitch_random_shift: float = 0
