extends InputComponent

@export var toggle_crouch: bool = false

var _horizontal_movement: float = 0
var _crouching := false
var _jump_held := false
var _fire_held := false
var _mouse_world_pos
var _charge_fire_held := false
var _interacting := false
var _superjump_held:= false
var _switch_gun := false

var _input_locked := false
var _jump_locked := false
var _superjump_enabled: bool = false

signal hasLanded
signal standing
signal crouching


func _ready() -> void:
	_superjump_enabled = get_parent().has_gun
	EventManager.connect("begin_date_scene_lock", _lock_input)
	EventManager.connect("end_date_scene_lock", _resume_input)
	EventManager.gun_picked_up.connect(_enable_superjump)

func _process(_delta: float) -> void:
	if not _input_locked:
		_horizontal_movement = Input.get_axis("move_left", "move_right")
		_mouse_world_pos = _get_mouse_world_position()
		_superjump_held = Input.is_action_pressed("super")
		
	else:
		# Reset all inputs to off. Stops things like repeatedly shooting if you were holding down shoot when a date started.
		_horizontal_movement = 0
		_crouching = false
		_jump_held = false
		_fire_held = false
		_charge_fire_held = false
		_interacting = false
		_switch_gun = false

	##This stops the player from holding the jump button and jumping
	#if _jump_locked:
		#_jump_held = false

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
		"interacting": _interacting,
		"superjump_held": _superjump_held,
		"switch_gun": _switch_gun,
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

func _lock_input() -> void:
	_input_locked = true

func _resume_input() -> void:
	_input_locked = false

func _enable_superjump() -> void:
	_superjump_enabled = true

func _physics_process(delta: float) -> void:
	pass

# Use this for things that are non-continuous.
func _unhandled_input(event: InputEvent) -> void:
	if _input_locked:
		return
	
	# -- Actions pressed --
	
	if event.is_action_pressed("fire"):
		_fire_held = true
	
	if event.is_action_pressed("shoot_charged"):
		_charge_fire_held = true
	
	if event.is_action_pressed("jump"):
		_jump_held = true                            ##Player jumps
	
	if event.is_action_pressed("super") and event.is_action_pressed("jump"):
		_jump_held = true
		_superjump_held = true
	
	if event.is_action_pressed("interact"):
		_interacting = true
		
	if event.is_action_pressed("move_down"):
		_crouching = true
		crouching.emit()
		
	if event.is_action_pressed("switch_gun") and not event.is_echo():
		_switch_gun = true
	
	# -- Actions released --
	
	if event.is_action_released("fire"):
		_fire_held = false
	
	if event.is_action_released("shoot_charged"):
		_charge_fire_held = false
	
	if event.is_action_released("jump"):
		_jump_held = false
		hasLanded.emit()
	
	if event.is_action_released("move_down"):
		if not toggle_crouch:
			_crouching = false
			standing.emit()
			#_on_player_crouch_overlap()
	
	if event.is_action_released("interact"):
		_interacting = false
