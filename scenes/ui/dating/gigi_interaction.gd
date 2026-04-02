extends Control

var _onDate = false

func _ready() -> void:
	## Hide the UI once game begins
	visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("gigi_show")
	## Toggle the UI using 'G' key
		_onDate = !_onDate
		if _onDate:
			_date_begin()
		else:
			_date_end()

## Make UI visible and show mouse
func _date_begin():
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

## Hide UI and hide mouse (position can still be tracked)
func  _date_close():
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
