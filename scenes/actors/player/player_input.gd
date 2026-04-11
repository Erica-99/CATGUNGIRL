extends InputComponent

@export var toggle_crouch: bool = false

var _horizontal_movement: float = 0
var _crouching := false
var _jump_held := false
var _fire_held := false

func _process(_delta: float) -> void:
	_horizontal_movement = Input.get_axis("move_left", "move_right")

## Return a comprehensive list of the current input state regardless of whether everything will actually be used.
## Avoid running any actual input state retrieval in here.
func get_input_state() -> Dictionary:
	var input_state = {
		"movement": _horizontal_movement,
		"crouching": _crouching,
		"jumping": _jump_held,
		"fire_held": _fire_held
	}
	return input_state

# Use this for things that are non-continuous.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		_fire_held = true
	
	if event.is_action_pressed("jump"):
		_jump_held = true
	
	if event.is_action_released("fire"):
		_fire_held = false
	
	if event.is_action_released("jump"):
		_jump_held = false
	
	if event.is_action_pressed("move_down"):
		if toggle_crouch:
			_crouching = !_crouching
		else:
			_crouching = true
	
	if event.is_action_released("move_down"):
		if not toggle_crouch:
			_crouching = false
	
