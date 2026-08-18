extends Node

@export var music_player: AudioStreamPlayer
@export var music_tracks: Array[MusicTrack]
@export_range(10, 100, 1) var sfx_global_pool_size: int = 10
@export_range(10, 100, 1) var sfx_positional_pool_size: int = 10
@export var sound_effects: Array[CallableSFX]
@export var enemy_stingers: Array[CallableSFX]

var music_dict: Dictionary
var sfx_dict: Dictionary

var sfx_global_pool: Array[AudioStreamPlayer]
var sfx_positional_pool: Array[AudioStreamPlayer3D]

func _ready() -> void:
	# Build MusicTrack Dictionary
	for music: MusicTrack in music_tracks:
		music_dict[music.track_ref] = music
	
	# Build CallableSFX Dictionary
	for sound_effect: CallableSFX in sound_effects:
		sfx_dict[sound_effect.sfx_ref] = sound_effect
	
	# Generate sfx global ASP pool (adjust size with sfx_global_pool_size)
	for i in range(sfx_global_pool_size):
		var asp := AudioStreamPlayer.new()
		asp.autoplay = false
		asp.bus = "SFX"  # optional
		asp.finished.connect(on_sfx_finished)
		add_child(asp)
		sfx_global_pool.append(asp)
	
	# Generate sfx positional ASP pool (adjust size with sfx_positional_pool_size)
	for i in range(sfx_positional_pool_size):
		var asp := AudioStreamPlayer3D.new()
		asp.autoplay = false
		asp.bus = "SFX"  # optional
		asp.finished.connect(on_sfx_finished)
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
func play_sfx(sfx_ref: String, loop: bool = false):
	
	var sound_effect: SoundEffect = get_sfx_from_dict(sfx_ref)
	
	# Check SoundEffect Resource was found
	if sound_effect == null:
		push_error("SFX Resource is not found")
	else:
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
				push_error("Global SFX ASP pool exceded")
			else:
			# Configure ASP node
				asp.stream = sound_effect.sound_clip
				asp.stream.loop = loop
				asp.volume_db = sound_effect.volume
				asp.pitch_scale = sound_effect.pitch_scale + randf_range(-sound_effect.pitch_random_shift, sound_effect.pitch_random_shift)
				
				# Connect finished signal
				asp.finished.disconnect(on_sfx_finished)
				asp.finished.connect(on_sfx_finished.bind(sound_effect))
				
				# Play sound effect
				asp.play()
				
				# Return asp ref if looping for termination control
				if loop:
					return asp
		else:
			push_error("Limit for '" + sfx_ref + "' exceeded")


# Play positional sound effect with an in-game location (best for enemies, hits, etc.)
func play_sfx_at_location(sfx_ref: String, location: Vector3, loop: bool = false):
	
	var sound_effect: SoundEffect = get_sfx_from_dict(sfx_ref)
	# Check SoundEffect Resource was found
	if sound_effect == null:
		push_error("SFX Resource is not found")
	else:
		# Check sfx limit
		if sound_effect.has_open_limit():
			# Adjust limit as necessary
			sound_effect.change_audio_count(1)
			
			# Assign avalible ASP node
			var asp3d: AudioStreamPlayer3D = null
			for player in sfx_positional_pool:
				if player.playing == false:
					asp3d = player
					break
			if asp3d == null: # Alert dev if sfx pool limit is exceded (likely will change to a fallback solution later)
				print("Positional sfx pool exceded")
			else:
			# Configure ASP node
				asp3d.stream = sound_effect.sound_clip
				asp3d.stream.loop = loop
				asp3d.volume_db = sound_effect.volume
				asp3d.pitch_scale = sound_effect.pitch_scale + randf_range(-sound_effect.pitch_random_shift, sound_effect.pitch_random_shift)
				asp3d.global_position = location
				
				# Connect finished signal
				asp3d.finished.disconnect(on_sfx_finished) # Close existing connection
				asp3d.finished.connect(on_sfx_finished.bind(sound_effect)) # Open new connection
				
				# Play sound effect
				asp3d.play()
				
				# Return asp3d ref if looping for termination control
				if loop:
					return asp3d


# Retrieves a sound effect resource from a SoundEffect or SoundEffectPool in the sfx_dict, that matches sfx_ref
func get_sfx_from_dict(sfx_ref: String) -> SoundEffect:
	if sfx_dict.has(sfx_ref):
		# Assign callable_sfx locally
		var callable_sfx: CallableSFX = sfx_dict[sfx_ref]
		# Get Sound Effect resource (will select a random Sound Effect entry if 
		# SoundEffectPool, otherwise returns same as callable_sfx)
		return callable_sfx.get_sfx()
	else: 
		push_error("No entry in sound effect register matching '" + sfx_ref + "'" )
		return null

func on_sfx_finished(sfx: SoundEffect):
	sfx.on_audio_finished()
