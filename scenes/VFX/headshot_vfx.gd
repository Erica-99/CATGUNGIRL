extends CPUParticles3D

func _ready() -> void:
	emitting = true

func delete_self():
	print("vfx freed")
	queue_free()
