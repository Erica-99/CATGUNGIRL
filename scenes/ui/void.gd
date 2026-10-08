extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.instant_void.connect(_activate_instant_void)

func _activate_instant_void(make_visible: bool) -> void:
	visible = make_visible
	if make_visible:
		EventManager.begin_date_scene_lock.emit()
	else:
		EventManager.end_date_scene_lock.emit()
