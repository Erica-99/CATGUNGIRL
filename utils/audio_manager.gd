extends Node

@export var music_player: AudioStreamPlayer
@export var music_tracks: Array[MusicTrack]
@export_range(10, 100, 1) var sfx_global_pool_size: int = 10
@export_range(10, 100, 1) var sfx_positional_pool_size: int = 10
@export var sound_effects: Array[SoundEffect]

var music_dict: Dictionary
var sfx_dict: Dictionary

var sfx_global_pool: Array[AudioStreamPlayer]
var sfx_positional_pool: Array[AudioStreamPlayer3D]


func _ready() -> void:
	
	# Assign music dict keys
	for music: MusicTrack in music_tracks:
		music_dict[music.track_ref] = music
	
	# Assign sfx dict keys
	for sound_effect: SoundEffect in sound_effects:
		sfx_dict[sound_effect.sfx_ref] = sound_effect
	
	# Generate sfx global node pool
	for i in range(sfx_global_pool_size):
		var asp := AudioStreamPlayer.new()
		asp.autoplay = false
		asp.bus = "SFX"  # optional
		add_child(asp)
		sfx_global_pool.append(asp)
	
	# Generate sfx positional node pool
	for i in range(sfx_positional_pool_size):
		var asp := AudioStreamPlayer3D.new()
		asp.autoplay = false
		asp.bus = "SFX"  # optional
		add_child(asp)
		sfx_positional_pool.append(asp)

# Play music track
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
		push_error("Music track not found")

# Play global sound effect (best for menu, UI, most player sounds, etc.)
func play_sfx(sfx_ref: String):
	# Check valid ref
	if sfx_dict.has(sfx_ref):
		# Assign sound effect locally
		var sound_effect: SoundEffect = sfx_dict[sfx_ref]
		# Check sfx limit
		if sound_effect.has_open_limit():
			# Adjust limit as necessary
			sound_effect.change_audio_count(1)
			# Assign avalible ASP node
			var asp: AudioStreamPlayer = null
			for player in sfx_global_pool:
				if player.playing == false:
					asp = player
					break
			if asp == null: # Alert dev if sfx global pool limit is exceded (likely will change to a fallback solution later)
				print("Global sfx pool exceded")
			# Configure ASP node
			asp.stream = sound_effect.sound_clip
			asp.volume_db = sound_effect.volume
			asp.pitch_scale = sound_effect.pitch_scale + randf_range(-sound_effect.pitch_random_shift, sound_effect.pitch_random_shift)
			# Connect finished signal
			if not asp.finished.is_connected(sound_effect.on_audio_finished):
				asp.finished.connect(sound_effect.on_audio_finished)
			# Play sound effect
			asp.play()
	else:
		push_error("Sound effect not found")

# Play positional sound effect with an in-game location (best for enemies, hits, etc.)
func play_sfx_at_location(sfx_ref: String, location: Vector3):
	# Check valid ref
	if sfx_dict.has(sfx_ref):
		# Assign sound effect locally
		var sound_effect: SoundEffect = sfx_dict[sfx_ref]
		# Check sfx limit
		if sound_effect.has_open_limit():
			# Adjust limit as necessary
			sound_effect.change_audio_count(1)
			# Assign avalible ASP node
			var asp: AudioStreamPlayer = null
			for player in sfx_global_pool:
				if player.playing == false:
					asp = player
					break
			if asp == null: # Alert dev if sfx global pool limit is exceded (likely will change to a fallback solution later)
				print("Global sfx pool exceded")
			# Configure ASP node
			asp.stream = sound_effect.sound_clip
			asp.volume_db = sound_effect.volume
			asp.pitch_scale = sound_effect.pitch_scale + randf_range(-sound_effect.pitch_random_shift, sound_effect.pitch_random_shift)
			# Connect finished signal
			if not asp.finished.is_connected(sound_effect.on_audio_finished):
				asp.finished.connect(sound_effect.on_audio_finished)
			# Play sound effect
			asp.play()
	else:
		push_error("Sound effect not found")
