extends Control

var isDating


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("date_show")):
		isDating = !isDating
	if isDating:
		visible = true
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		visible = false
		#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
