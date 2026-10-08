extends Node3D

@export var music_ref: String
## Untick for stages with their own music (e.g. the Brain Jar fight) so the combat music stays off
@export var combat_music: bool = true
@export var play_start_comic: bool

func _ready() -> void:
	# lets MusicIntensityManager know this stage uses combat music
	if combat_music:
		add_to_group("combat_music_stage")

	AudioManager.play_music(music_ref)
	
	if play_start_comic:
		EventManager.instant_void.emit(true)
		EventManager.play_comic.emit("start_comic")
