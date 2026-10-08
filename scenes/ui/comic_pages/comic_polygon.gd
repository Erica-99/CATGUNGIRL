extends Polygon2D
class_name ComicPolygon

func _trigger_fade() -> void:
	$AnimationPlayer.play("fade")
