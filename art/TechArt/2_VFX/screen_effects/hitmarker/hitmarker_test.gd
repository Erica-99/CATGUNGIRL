extends Node

const KEYS := {KEY_1: &"body", KEY_2: &"headshot", KEY_3: &"shield", KEY_4: &"kill"}

@onready var hitmarker: Hitmarker = $Hitmarker

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hitmarker.trigger(&"body")
	elif event is InputEventKey and event.pressed and not event.echo and KEYS.has(event.keycode):
		hitmarker.trigger(KEYS[event.keycode])
