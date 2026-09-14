extends Node

signal input_device_changed(using_controller: bool)

var _using_controller: bool = false

const _JOYPAD_MOTION_DEADZONE: float = 0.5


func _ready() -> void:
	if Input.get_connected_joypads().size() == 0:
		_using_controller = false
	else:
		_using_controller = true


func _input(event: InputEvent) -> void:
	var was_using_controller := _using_controller
	
	if event is InputEventJoypadButton:
		_using_controller = true
	elif event is InputEventJoypadMotion and absf(event.axis_value) > _JOYPAD_MOTION_DEADZONE:
		_using_controller = true
	elif event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		_using_controller = false
	
	if _using_controller != was_using_controller:
		input_device_changed.emit(_using_controller)


func is_using_controller() -> bool:
	return _using_controller


func get_controller_family() -> StringName:
	if Input.get_connected_joypads().size() == 0:
		return &"none"

	var joypads := Input.get_connected_joypads()
	
	var joy_name := Input.get_joy_name(joypads[0]).to_lower()
	
	if "xbox" in joy_name:
		return &"xbox"
	if "playstation" in joy_name or "dualshock" in joy_name or "dualsense" in joy_name or "sony" in joy_name \
			or "ps3" in joy_name or "ps4" in joy_name or "ps5" in joy_name:
		return &"playstation"
	
	return &"generic"
