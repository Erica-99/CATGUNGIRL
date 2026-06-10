extends InsanityEffect

@export var jitter_amount_1: float = 1
@export var jitter_amount_2: float = 2
@export var jitter_amount_3: float = 3
@export var jitter_amount_4: float = 4
@export var jitter_amount_5: float = 5

var max_offset: float = 0
var parent: Control
var original_pos: Vector2


func alt_ready() -> void:
	parent = get_parent()
	await get_tree().process_frame
	original_pos = parent.position

func change_effect_1() -> void:
	max_offset = jitter_amount_1

func change_effect_2() -> void:
	max_offset = jitter_amount_2

func change_effect_3() -> void:
	max_offset = jitter_amount_3

func change_effect_4() -> void:
	max_offset = jitter_amount_4

func change_effect_5() -> void:
	max_offset = jitter_amount_5

func _process(_delta: float) -> void:
	
	var offset = Vector2(
		randf_range(-max_offset, max_offset),
		randf_range(-max_offset, max_offset)
	)
	
	parent.position = original_pos + offset
