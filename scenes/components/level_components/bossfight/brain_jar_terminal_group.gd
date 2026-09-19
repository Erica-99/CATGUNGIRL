extends Node3D
class_name BrainJarTerminalGroup

@export var interaction_console: Node3D
@export var terminal_light: Light3D
@export var terminal_visuals: Array[Node3D] = []

@export_category("Terminal Materials")
@export var active_material: Material
@export var inactive_material: Material

var terminal_meshes: Array[MeshInstance3D] = []

func _ready() -> void:
	for terminal_visual in terminal_visuals:
		var terminal_mesh := terminal_visual.find_child("BrainJarTerminal_Mesh", true, false) as MeshInstance3D
		
		if terminal_mesh != null:
			terminal_meshes.append(terminal_mesh)
	
	set_active_visual(false)

func set_active_visual(is_active: bool) -> void:
	var selected_material: Material = active_material if is_active else inactive_material
	
	if selected_material != null:
		for terminal_mesh in terminal_meshes:
			terminal_mesh.set_surface_override_material(0, selected_material)
	
	if terminal_light != null:
		terminal_light.visible = is_active

func get_interactable_component() -> Node:
	if interaction_console == null:
		return null
	
	return interaction_console.find_child("InteractableComponent", true, false)
