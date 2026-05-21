extends Resource
class_name MusicTrack

@export var track_ref: String
@export var music_track: AudioStreamMP3
@export_range(-40, 20) var volume: float = 0
