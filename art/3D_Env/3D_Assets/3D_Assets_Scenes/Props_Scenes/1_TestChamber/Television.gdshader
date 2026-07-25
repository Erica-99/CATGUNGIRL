
func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS

func _unhandled_input(event: InputEvent):
	
	if event is InputEventMouse:
		
		# Remap the coorinates of a mouse event to be at an apropriate point
		event.position -= position
		event.position *= Vector2(Vector2(subviewport_node.size) / size)
	
	subviewport_node.push_input(event)