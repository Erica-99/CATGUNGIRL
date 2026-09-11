class_name FogOfWarManager
extends Node3D


const MAX_REGIONS := 32
const MATERIAL_PATH := "res://art/TechArt/1_Shaders/Spatial/FogOfWar/SM_FogOfWar.tres"

@export_range(0.1, 10.0, 0.1) var quad_distance: float = 1.0

@export_group("Region depth")
@export var region_z_center: float = 5.0
@export var region_z_extent: float = 55.0

var _quad: MeshInstance3D
var _material: ShaderMaterial
var _bounds := PackedVector4Array()
var _params := PackedVector4Array()


func _ready() -> void:
	_bounds.resize(MAX_REGIONS)
	_params.resize(MAX_REGIONS)
	_build_quad()


func _build_quad() -> void:
	var source := load(MATERIAL_PATH) as ShaderMaterial

	var mesh := QuadMesh.new()
	mesh.size = Vector2(2.0, 2.0)
	mesh.flip_faces = true

	_material = source.duplicate()

	_quad = MeshInstance3D.new()
	_quad.name = "FogOfWarScreen"
	_quad.mesh = mesh
	_quad.material_override = _material
	_quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_quad.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	_quad.extra_cull_margin = 16384.0
	add_child(_quad)


func _process(delta: float) -> void:
	_pin_quad_to_camera()

	var player := _resolve_player()
	var has_player := player != null
	var player_position := player.global_position if has_player else Vector3.ZERO

	var visible_regions := _update_regions(delta, player_position, has_player)
	_upload(visible_regions)


func _pin_quad_to_camera() -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	_quad.global_transform = camera.global_transform.translated_local(
			Vector3(0.0, 0.0, -quad_distance))
	_material.set_shader_parameter(&"plane_depth", absf(camera.global_position.z))


func _update_regions(delta: float, player_position: Vector3, has_player: bool) -> Array:
	var contributing := []
	for node in get_tree().get_nodes_in_group(FogOfWarRegion.GROUP):
		var region := node as FogOfWarRegion
		if region == null or not region.is_inside_tree():
			continue
		region.refresh_bounds(region_z_center, region_z_extent)
		region.update_reveal(delta, player_position, has_player)
		if region.reveal > 0.0:
			contributing.append(region)

	if contributing.size() > MAX_REGIONS:
		if has_player:
			contributing.sort_custom(func(a: FogOfWarRegion, b: FogOfWarRegion) -> bool:
					return a.signed_distance(player_position) < b.signed_distance(player_position))
		contributing.resize(MAX_REGIONS)

	return contributing


func _upload(regions: Array) -> void:
	for i in MAX_REGIONS:
		if i < regions.size():
			var region: FogOfWarRegion = regions[i]
			_bounds[i] = region.get_gpu_bounds()
			_params[i] = Vector4(region.feather, region.reveal, 0.0, 0.0)
		else:
			_bounds[i] = Vector4.ZERO
			_params[i] = Vector4.ZERO

	_material.set_shader_parameter(&"region_count", regions.size())
	_material.set_shader_parameter(&"region_bounds", _bounds)
	_material.set_shader_parameter(&"region_params", _params)
	_material.set_shader_parameter(&"region_z_center", region_z_center)
	_material.set_shader_parameter(&"region_z_extent", region_z_extent)


func _resolve_player() -> Node3D:
	var player := get_tree().get_first_node_in_group(&"player")
	if player == null:
		player = get_tree().get_first_node_in_group(&"Player")
	return player as Node3D
