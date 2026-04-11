## InputComponent
## Kind of an interface except gdscript does support interfaces.
## Has a queryable input state which returns a dictionary of different components of input state e.g. movement, attack, etc.

extends Node
class_name InputComponent

func get_input_state() -> Dictionary:
	return Dictionary()
