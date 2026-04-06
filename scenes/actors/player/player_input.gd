extends InputComponent

@export var toggle_crouch: bool = false

var _horizontal_movement: float = 0
var _crouching := false
var _jump_held := false
var _fire_held := false
var _mouse_world_pos
var _charge_fire_held := false

func _process(_delta: float) -> void:
	_horizontal_movement = Input.get_axis("move_left", "move_right")
	_mouse_world_pos = _get_mouse_world_position()

## Return a comprehensive list of the current input state regardless of whether everything will actually be used.
## Avoid running any actual input state retrieval in here.
func get_input_state() -> Dictionary:
	var input_state = {
		"movement": _horizontal_movement,
		"crouching": _crouching,
		"jumping": _jump_held,
		"fire_held": _fire_held,
		"mouse_world_pos": _mouse_world_pos,
		"charge_fire_held": _charge_fire_held,
	}
	return input_state

## projects 2D mouse position onto 3D world
func _get_mouse_world_position() -> Variant:
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return null
	
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	var plane = Plane(Vector3(0.0, 0.0, 1.0), 0)
	
	return plane.intersects_ray(ray_origin, ray_dir)

# Use this for things that are non-continuous.
func _unhandled_input(event: InputEvent) -> void:
	
	# -- Actions pressed --
	
	if event.is_action_pressed("fire"):
		_fire_held = true
	
	if event.is_action_pressed("shoot_charged"):
		_charge_fire_held = true
	
	if event.is_action_pressed("jump"):
		_jump_held = true
	
	if event.is_action_pressed("move_down"):
		if toggle_crouch:
			_crouching = !_crouching
		else:
			_crouching = true
	
	# -- Actions released --
	
	if event.is_action_released("fire"):
		_fire_held = false
	
	if event.is_action_released("shoot_charged"):
		_charge_fire_held = false
	
	if event.is_action_released("jump"):
		_jump_held = false
	
	if event.is_action_released("move_down"):
		if not toggle_crouch:
			_crouching = false
	
