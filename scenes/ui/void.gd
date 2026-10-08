extends CanvasLayer

signal slow_void_finished(now_visible: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.instant_void.connect(_activate_instant_void)
	EventManager.slow_void.connect(_activate_slow_void)

func _activate_instant_void(make_visible: bool) -> void:
	visible = make_visible
	$VoidAnimationPlayer.play("blank")
	if make_visible:
		EventManager.begin_date_scene_lock.emit()
	else:
		EventManager.end_date_scene_lock.emit()

func _activate_slow_void(make_visible: bool) -> void:
	visible = make_visible
	if make_visible:
		EventManager.begin_date_scene_lock.emit()
		$VoidAnimationPlayer.play("fade_in")
	else:
		EventManager.end_date_scene_lock.emit()
		$VoidAnimationPlayer.play("fade_out")


func _on_void_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		slow_void_finished.emit(true)
	elif anim_name == "fade_out":
		slow_void_finished.emit(false)
