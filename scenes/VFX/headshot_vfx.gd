extends CPUParticles3D

func play() -> void:
	emitting = true

func delete_self():
	print("vfx freed")
	queue_free()
