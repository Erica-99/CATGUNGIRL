extends PanelContainer

@onready var rich_text_label: RichTextLabel = $RichTextLabel

@export var transparency_rate: float = 0.01

var centred_position = Vector2.ZERO


signal is_transparent

func _ready() -> void:
	var viewport: Vector2 = Vector2(get_viewport().size)
	position = Vector2(viewport.x / 2, viewport.y - 100)
	centred_position = _get_position_around_origin()


func _process(delta: float) -> void:
	self_modulate.a -= transparency_rate
	if self_modulate.a < 0:
		emit_signal("is_transparent", self)


func _set_text(text: String) -> void:
	rich_text_label.text = text


func _get_position_around_origin() -> Vector2:
	var origin_position = position
	origin_position.x -= size.x / 2
	origin_position.y -= size.y / 2
	return origin_position


func _set_position_off_index(index: int = 0) -> void:
	centred_position.y -= (10 * index)
	position = centred_position
