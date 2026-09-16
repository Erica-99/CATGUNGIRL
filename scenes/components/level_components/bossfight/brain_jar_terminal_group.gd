extends Node3D
class_name BrainJarTerminalGroup

@export var interaction_console: Node3D
@export var terminal_light: Light3D
@export var terminal_visuals: Array[Node3D] = []
@export var active_emission_strength: float = 5.0

var terminal_materials: Array[StandardMaterial3D] = []

func _ready() -> void:
	for terminal_visual in terminal_visuals:
		var terminal_mesh: MeshInstance3D = terminal_visual.find_child("BrainJarTerminal_Mesh", true, false) as MeshInstance3D
		
		if terminal_mesh == null:
			continue
		
		var source_material: StandardMaterial3D = (terminal_mesh.get_active_material(0) as StandardMaterial3D)
		
		if source_material == null:
			continue
		
		var unique_material: StandardMaterial3D = (source_material.duplicate() as StandardMaterial3D)
		terminal_mesh.set_surface_override_material(0, unique_material)
		terminal_materials.append(unique_material)
	
	set_active_visual(false)

func set_active_visual(is_active: bool) -> void:
	for terminal_material in terminal_materials:
		terminal_material.emission_enabled = is_active
		terminal_material.emission_energy_multiplier = (active_emission_strength if is_active else 0.0)
	
	if terminal_light != null:
		terminal_light.visible = is_active

func get_interactable_component() -> Node:
	if interaction_console == null:
		return null
	
	return interaction_console.find_child("InteractableComponent", true, false)
