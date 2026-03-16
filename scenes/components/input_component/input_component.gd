extends Node
class_name InputComponent

signal input_signal(event: InputEvent)

func _unhandled_input(event: InputEvent) -> void:
	input_signal.emit(event)


# Need to create an input state which both can be queried and 
# also forwards input events down the chain.

func get_input_state():
	pass
