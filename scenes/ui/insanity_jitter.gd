extends InsanityEffect

var max_offset: float = 0
var parent: Control
var original_pos: Vector2

func alt_ready() -> void:
	parent = get_parent()
	await get_tree().process_frame
	original_pos = parent.position

func change_effect_1() -> void:
	max_offset = 1

func change_effect_2() -> void:
	max_offset = 2

func change_effect_3() -> void:
	max_offset = 3

func change_effect_4() -> void:
	max_offset = 4

func change_effect_5() -> void:
	max_offset = 5

func _process(_delta: float) -> void:
	
	var offset = Vector2(
		randf_range(-max_offset, max_offset),
		randf_range(-max_offset, max_offset)
	)
	
	parent.position = original_pos + offset
