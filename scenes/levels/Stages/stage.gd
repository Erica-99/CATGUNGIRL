extends Node3D

@export var music_ref: String
## Untick for stages with their own music (e.g. the Brain Jar fight) so the combat music stays off
@export var combat_music: bool = true

func _ready() -> void:
	# lets MusicIntensityManager know this stage uses combat music
	if combat_music:
		add_to_group("combat_music_stage")

	AudioManager.play_music(music_ref)
