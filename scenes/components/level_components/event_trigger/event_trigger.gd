@tool
extends Area3D

@export var active := true
@export var _one_shot := true

@export_group("Signal")
# --- All this below literally just makes a dropdown for signals. ---
var _signal_name: String = ""

func _get_property_list():
	var signal_names: PackedStringArray = []
	
	var event_manager_script := load("res://utils/event_manager.gd")
	
	for sig in event_manager_script.get_script_signal_list():
		signal_names.append(sig.name)
	
	return [{
		"name": "signal_name",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(signal_names)
	}]

func _get(property):
	if property == "signal_name":
		return _signal_name
	return null

func _set(property, value):
	if property == "signal_name":
		_signal_name = value
		return true
	return false
# -------------------------------------------------------------------

@export var _signal_parameters: Array[Variant]

@export_tool_button("Refresh Signal List", "Reload")
var refresh_action = notify_property_list_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	notify_property_list_changed()

func activate():
	active = true

func deactivate():
	active = false

func _on_body_entered(body: Node3D) -> void:
	if not active:
		return
	
	var emit_function_params = _signal_parameters.duplicate()
	emit_function_params.insert(0, _signal_name)
	EventManager.emit_signal.callv(emit_function_params)
	if _one_shot:
		deactivate()
