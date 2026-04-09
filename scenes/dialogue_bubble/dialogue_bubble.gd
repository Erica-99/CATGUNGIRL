extends PanelContainer

@onready var rich_text_label: RichTextLabel = $RichTextLabel

@export var time_till_transparent: float = 4

var centred_position: Vector2 = Vector2.ZERO
var viewport: Vector2 = Vector2.ZERO
var rate_of_transparency: float = 0

signal is_transparent

func _ready() -> void:
	viewport = Vector2(get_viewport().size)
	centred_position = _get_position_around_origin()
	rate_of_transparency = modulate.a / (time_till_transparent * 60)

func _process(delta: float) -> void:
	modulate.a -= rate_of_transparency
	if modulate.a < 0:
		emit_signal("is_transparent", self)


func _set_text(text: String) -> void:
	rich_text_label.text = text


func _get_position_around_origin() -> Vector2:
	var origin_position = position
	origin_position.x -= size.x / 2
	origin_position.y -= size.y / 2
	return origin_position


func _set_position_off_index(index: int = 0) -> void:
	position.y = centred_position.y - (50 * index)
