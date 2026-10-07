extends CanvasLayer
class_name Hitmarker

@export var anim: AnimationPlayer
@export var follow_mouse := true

func _process(_delta: float) -> void:
	if follow_mouse and anim.is_playing():
		place_at(get_viewport().get_mouse_position())

func place_at(canvas_position: Vector2) -> void:
	var stretch := get_viewport().get_final_transform().get_scale()
	offset = canvas_position
	scale = Vector2(1.0 / maxf(stretch.x, 0.001), 1.0 / maxf(stretch.y, 0.001))

func trigger(type: StringName) -> void:
	if anim.is_playing() and anim.current_animation == &"kill" and type != &"kill":
		return
	if follow_mouse:
		place_at(get_viewport().get_mouse_position())
	anim.play(type)
	anim.seek(0.0, true)
