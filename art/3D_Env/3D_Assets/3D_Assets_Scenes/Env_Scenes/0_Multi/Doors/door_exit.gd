extends StaticBody3D

var unlocked_colour
var level_end
@export var shield_mesh: GeometryInstance3D
@export var wait_for_event: String

var event_condition_filled = true
var enemies_defeated = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	##Get the LevelEnd component
	await get_tree().process_frame
	level_end = find_child("LevelEnd", true, false)
	##Create the unlocked colour for door lights
	unlocked_colour = StandardMaterial3D.new()
	unlocked_colour.albedo_color = Color(0 ,1.0, 0)
	unlocked_colour.emission_color = Color(0, 1.0, 0)
	if wait_for_event != null and EventManager.has_signal(wait_for_event):
		EventManager.connect(wait_for_event, _extra_event_triggered)
		event_condition_filled = false


func _change_door_lighting():
	if !has_node("EXITHERECYLINDER") or !has_node("EXITHERECYLINDER2"):
		return
	
	$EXITHERECYLINDER.material_override = unlocked_colour
	$EXITHERECYLINDER2.material_override = unlocked_colour


func _on_enemy_manager_stage_cleared() -> void:
	enemies_defeated = true
	if event_condition_filled:
		open_door()

func _extra_event_triggered() -> void:
	event_condition_filled = true
	if enemies_defeated:
		open_door()

func open_door() -> void:
	_change_door_lighting()
	
	if shield_mesh != null:
		shield_mesh.material_overlay = null
	
	if level_end != null:
		level_end.set_deferred("monitoring", true)
