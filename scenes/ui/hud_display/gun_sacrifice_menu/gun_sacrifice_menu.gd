extends CanvasLayer
class_name GunSacrificeMenu

signal gun_selected(gun: Node3D)

@onready var menu_root: Control = $MenuRoot
@export var pistol_button: Button
@export var shotgun_button: Button
@export var sniper_button: Button

var guns_by_button: Dictionary = {}
var is_open: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_to_group("gun_sacrifice_menu")
	menu_root.hide()
	pistol_button.pressed.connect(_on_gun_pressed.bind(pistol_button))
	shotgun_button.pressed.connect(_on_gun_pressed.bind(shotgun_button))
	sniper_button.pressed.connect(_on_gun_pressed.bind(sniper_button))

func open_menu(gun_holder: Node3D) -> bool:
	if is_open or get_tree().paused or !is_instance_valid(gun_holder):
		return false
	
	guns_by_button.clear()
	_hide_button(pistol_button)
	_hide_button(shotgun_button)
	_hide_button(sniper_button)
	
	for child in gun_holder.get_children():
		if child is not Node3D:
			continue
		
		if child.get_index() in gun_holder.gun_indexes_sacrificed:
			continue
		
		var button := _get_button_for_gun(child)
		
		if button != null:
			button.show()
			button.disabled = false
			guns_by_button[button] = child
	
	if guns_by_button.is_empty():
		return false
	
	is_open = true
	menu_root.show()
	get_tree().paused = true
	
	for button in guns_by_button:
		button.grab_focus()
		break
	
	return true

func _get_button_for_gun(gun: Node3D) -> Button:
	var gun_name_lower: String = str(gun.get("gun_name")).to_lower()
	
	if gun_name_lower.contains("pistol"):
		return pistol_button
	
	if gun_name_lower.contains("shotgun"):
		return shotgun_button
	
	if gun_name_lower.contains("sniper"):
		return sniper_button
	
	push_warning("No sacrifice menu button for gun: " + gun.gun_name)
	return null

func _hide_button(button: Button) -> void:
	button.hide()
	button.disabled = true

func _on_gun_pressed(button: Button) -> void:
	var selected_gun := guns_by_button.get(button) as Node3D
	
	match selected_gun.name:
		"Pistol":
			EventManager.activate_popup.emit("b5_kill_cozy")
		"Shotgun":
			EventManager.activate_popup.emit("b5_kill_punk")
		"Sniper":
			EventManager.activate_popup.emit("b5_kill_soldier")
	
	if !is_instance_valid(selected_gun):
		return
	
	gun_selected.emit(selected_gun)
	close_menu()

func close_menu() -> void:
	if !is_open:
		return
	
	is_open = false
	menu_root.hide()
	get_tree().paused = false
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if is_open and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu()

func _exit_tree() -> void:
	if is_open:
		get_tree().paused = false
