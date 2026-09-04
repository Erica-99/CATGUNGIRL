extends Node

@export_category("Music")
@export var music_player: AudioStreamPlayer
@export var music_tracks: Array[MusicTrack]

@export_category("SFX")
@export_range(10, 100, 1) var sfx_global_pool_size: int = 10
@export_range(10, 100, 1) var sfx_3D_pool_size: int = 10
@export var sound_effects: Array[CallableSFX]

@export_category("Stingers")
@export var enemy_stingers: Array[CallableSFX]

var music_dict: Dictionary
var sfx_dict: Dictionary
var stinger_dict: Dictionary

var sfx_global_pool: Array[AudioStreamPlayer]
var sfx_3D_pool: Array[AudioStreamPlayer3D]

var hotseat: AudioStreamPlayer3D

func _ready() -> void:
	#region Audio Dictionary Construction
	# Build MusicTrack Dictionary
	for music: MusicTrack in music_tracks:
		music_dict[music.track_ref] = music
	
	# Build CallableSFX Dictionary
	for sound_effect: CallableSFX in sound_effects:
		sfx_dict[sound_effect.sfx_ref] = sound_effect
	
	# Build Stinger Dictionary
	for stinger: CallableSFX in enemy_stingers:
		stinger_dict[stinger.sfx_ref] = stinger
	#endregion
	
	#region ASP Pool Generation
	# Generate global sfx ASP pool (adjust size with sfx_global_pool_size)
	for i in range(sfx_global_pool_size):
		var asp := AudioStreamPlayer.new()
		asp.autoplay = false
		asp.bus = "SFX"  # optional
		asp.finished.connect(on_sfx_finished)
		add_child(asp)
		sfx_global_pool.append(asp)
	
	# Generate 3D sfx ASP pool (adjust size with sfx_positional_pool_size)
	for i in range(sfx_3D_pool_size):
		var asp := AudioStreamPlayer3D.new()
		asp.autoplay = false
		asp.bus = "SFX"  # optional
		asp.finished.connect(on_sfx_finished)
		add_child(asp)
		sfx_3D_pool.append(asp)
	#endregion

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
				asp.volume_db = sound_effect.volume
				asp.pitch_scale = sound_effect.pitch_scale + randf_range(-sound_effect.pitch_random_shift, sound_effect.pitch_random_shift)
				
				# Connect finished signal
				asp.finished.disconnect(on_sfx_finished)
				asp.finished.connect(on_sfx_finished.bind(sound_effect))
				
				# Play sound effect
				asp.play()
				
				# Return asp ref if for termination control
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
			for player in sfx_3D_pool:
				if player.playing == false:
					asp3d = player
					break
			if asp3d == null: # Alert dev if sfx pool limit is exceded (likely will change to a fallback solution later)
				print("Positional sfx pool exceded")
			else:
			# Configure ASP node
				asp3d.stream = sound_effect.sound_clip
				asp3d.volume_db = sound_effect.volume
				asp3d.pitch_scale = sound_effect.pitch_scale + randf_range(-sound_effect.pitch_random_shift, sound_effect.pitch_random_shift)
				asp3d.global_position = location
				
				# Connect finished signal
				asp3d.finished.disconnect(on_sfx_finished) # Close existing connection
				asp3d.finished.connect(on_sfx_finished.bind(sound_effect)) # Open new connection
				
				# Play sound effect
				asp3d.play()
				
				# Return asp3d ref for termination control
				return asp3d

func play_stinger(asp3d: AudioStreamPlayer3D, stinger_ref: String):
	if hotseat == null:
		take_hotseat(asp3d, stinger_ref)
	elif hotseat.playing == false:
		take_hotseat(asp3d, stinger_ref)
	else:
		play_sfx_at_location(stinger_ref, asp3d.global_position)

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

# Retrieves a sound effect resource from a SoundEffect or SoundEffectPool in the stinger_dict, that matches stinger_ref
func get_stinger_from_dict(stinger_ref: String) -> SoundEffect:
	if stinger_dict.has(stinger_ref):
		# Assign callable_sfx locally
		var callable_sfx: CallableSFX = stinger_dict[stinger_ref]
		# Get Sound Effect resource (will select a random Sound Effect entry if 
		# SoundEffectPool, otherwise returns same as callable_sfx)
		return callable_sfx.get_sfx()
	else: 
		push_error("No entry in stinger register matching '" + stinger_ref + "'" )
		return null

func on_sfx_finished(sfx: SoundEffect):
	sfx.on_audio_finished()

func configure_global_asp(asp: AudioStreamPlayer, sound_effect: SoundEffect) -> void:
	# Configure ASP node
	asp.stream = sound_effect.sound_clip
	asp.volume_db = sound_effect.volume
	asp.pitch_scale = sound_effect.pitch_scale + randf_range(-sound_effect.pitch_random_shift, sound_effect.pitch_random_shift)
		
	# Connect finished signal
	asp.finished.disconnect(on_sfx_finished)
	asp.finished.connect(on_sfx_finished.bind(sound_effect))


func configure_3D_asp(asp3d: AudioStreamPlayer3D, sound_effect: SoundEffect, location: Vector3) -> void:
	# Configure ASP node
	asp3d.stream = sound_effect.sound_clip
	asp3d.volume_db = sound_effect.volume
	asp3d.pitch_scale = sound_effect.pitch_scale + randf_range(-sound_effect.pitch_random_shift, sound_effect.pitch_random_shift)
	asp3d.global_position = location
				
	# Connect finished signal
	asp3d.finished.disconnect(on_sfx_finished) # Close existing connection
	asp3d.finished.connect(on_sfx_finished.bind(sound_effect)) # Open new connection
				

func take_hotseat(asp3d: AudioStreamPlayer3D, stinger_ref: String):
	var stinger: SoundEffect = get_stinger_from_dict(stinger_ref)
	if stinger == null:
		push_error("Stinger Resource is not found")
	else:
		hotseat = asp3d
		hotseat.stream = stinger.sound_clip
		hotseat.volume_db = stinger.volume
		hotseat.pitch_scale = stinger.pitch_scale + randf_range(-stinger.pitch_random_shift, stinger.pitch_random_shift)
			
		hotseat.play()

func play_fallback(asp3d: AudioStreamPlayer3D, stinger_ref: String) -> void:
	var fallback_ref: String
	if stinger_dict.has(stinger_ref):
		# Assign callable_sfx locally
		var callable_sfx: CallableSFX = stinger_dict[stinger_ref]
		# Get Sound Effect resource (will select a random Sound Effect entry if 
		# SoundEffectPool, otherwise returns same as callable_sfx)
		fallback_ref = callable_sfx.get_fallback_ref()
		
		if fallback_ref == null:
			return
		
		var fallback: SoundEffect = get_stinger_from_dict(fallback_ref)
		if fallback == null:
			push_error("Fallback Resource is not found")
			return
		
		asp3d.stream = fallback.sound_clip
		asp3d.volume_db = fallback.volume
		asp3d.pitch_scale = fallback.pitch_scale + randf_range(-fallback.pitch_random_shift, fallback.pitch_random_shift)
		
		asp3d.play()
		
	else: 
		push_error("No entry in stinger register matching '" + stinger_ref + "'" )
		
		
