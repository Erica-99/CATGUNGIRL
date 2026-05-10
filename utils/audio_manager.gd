extends Node

@export var music_player: AudioStreamPlayer
@export var music_tracks: Array[MusicTrack]
@export var sound_effects: Array[SoundEffect]

var music_dict: Dictionary
var sfx_dict: Dictionary


func _ready() -> void:
	# Assign music dict keys
	for music: MusicTrack in music_tracks:
		music_dict[music.track_ref] = music
	# Assign sfx dict keys
	for sound_effect: SoundEffect in sound_effects:
		sfx_dict[sound_effect.sfx_ref] = sound_effect
	
	
	pass




func play_music(track_ref: String):
	# Check if valid time to change track
	# if track is already playing
	# return
	# Check if track_ref is valid
	if music_dict.has(track_ref):
		# Change Audio Stram to music_track mp3
		var track: MusicTrack = music_dict[track_ref]
		music_player.stream = track.music_track
		music_player.volume_db = track.volume
		# Play Stream
		music_player.play()
	else:
		push_error("Audio file not found")
	
