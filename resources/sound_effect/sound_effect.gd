extends CallableSFX
class_name SoundEffect

@export var sound_clip: AudioStream
@export_range(1, 10) var limit: int = 5
@export_range(-40, 20) var volume: float = 0
@export_range(0.01, 4.0, 0.01) var pitch_scale: float = 1
@export_range(0.0, 1.0, 0.01) var pitch_random_shift: float = 0
@export_range(0.0, 5.0, 0.1) var pool_weighting: float = 1

var audio_count: int = 0

func get_sfx() -> SoundEffect:
	return self

## Takes [param amount] to change the [member audio_count]. 
func change_audio_count(amount: int) -> void:
	audio_count = max(0, audio_count + amount)

## Checkes whether the audio limit is reached. Returns true if the [member audio_count] is less than the [member limit].
func has_open_limit() -> bool:
	return audio_count < limit

## Connected to the [member sound_effect]'s finished signal to decrement the [member audio_count].
func on_audio_finished() -> void:
	change_audio_count(-1)
