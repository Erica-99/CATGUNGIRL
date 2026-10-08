extends CPUParticles3D

func delete_self():
	print("vfx freed")
	queue_free()
