extends AudioStreamPlayer3D
class_name StingerComponent

func play_stinger(ref: String, bypass: bool = false):
	AudioManager.play_stinger(self, ref, bypass)
