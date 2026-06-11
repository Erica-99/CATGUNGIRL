extends AnimatedSprite3D

func _ready() -> void:
	visible = false
	EventManager.pre_date_sequence.connect(_pre_date_sequence)

func _pre_date_sequence(date_id: int) -> void:
	visible = true
	EventManager.begin_date_scene_lock.emit()
	play()
	await get_tree().create_timer(2).timeout
	EventManager.activate_date.emit(date_id)
	visible = false
	stop()
