extends Sprite3D

@onready var sub_viewport: SubViewport = $SubViewport

# manually push input into subviewport
func _input(event: InputEvent) -> void:
	sub_viewport.push_input(event.duplicate())
