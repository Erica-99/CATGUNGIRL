extends Control
class_name ComicPage

signal comic_finished

@export var page_image: TextureRect
@export var polygons: Array[ComicPolygon]

var next_index_to_fade: int

func _ready() -> void:
	next_index_to_fade = 0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fire"):
		_fade_next()

func _fade_next() -> void:
	if next_index_to_fade >= polygons.size():
		_finish_comic()
	else:
		polygons[next_index_to_fade]._trigger_fade()
		next_index_to_fade += 1

func _finish_comic() -> void:
	comic_finished.emit()
