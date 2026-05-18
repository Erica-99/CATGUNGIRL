extends Node3D

## laser sight
@export_group("Aiming Laser")
@export var max_range: float = 40.0			# max laser length if nothing is hit
@export var laser_color: Color = Color.RED	# can change in inspector

@export_group("Indicator Laser")
@export var spread_color: Color = Color.RED	# spread laser color
@export var max_spread: float = 0.5
@export var side_laser_length: float = 2.0	# side laser max length
@export var pie_slices: int = 16			# higher = smoother
@export var fill_alpha: float = 0.4			# lower = more transparent

@export_group("Beam")
@export var beam_color: Color = Color.SKY_BLUE
@export var beam_duration: float = 0.2
@export var beam_width_min: float = 0.2
@export var beam_width_max: float = 1.0

@onready var ray_cast: RayCast3D = $RayCast3D
@onready var mesh_instance: MeshInstance3D = $LaserMeshInstance
@onready var beam_mesh_instance: MeshInstance3D = $BeamMeshInstance

var _current_spread: float = 0.0 # 0.0 = perfect shot (when laser converges), 1.0 = full spread (spam/max recoil)
var _beam_active: bool = false
var _beam_end: Vector3 = Vector3.ZERO
var _beam_timer: float = 0.0
var _beam_width: float = 0.0

func _ready() -> void:
	ray_cast.target_position = Vector3(max_range, 0.0, 0.0)
	mesh_instance.mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.material_override = material
	## BEAM
	beam_mesh_instance.mesh = ImmediateMesh.new()
	var beam_material = StandardMaterial3D.new()
	beam_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam_material.vertex_color_use_as_albedo = true
	beam_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	beam_mesh_instance.material_override = beam_material

func on_spread_changed(spread: float) -> void:
	_current_spread = spread

func on_beam_fired(beam_end: Vector3, charge_progress) -> void:
	_beam_end = beam_end
	_beam_active = true
	_beam_timer = beam_duration
	_beam_width = lerpf(beam_width_min, beam_width_max, charge_progress)

func _process(delta: float) -> void:
	if _beam_active:
		_beam_timer -= delta
		if _beam_timer <= 0.0:
			_beam_active = false
	_draw_laser()

func _draw_laser() -> void:
	var immediate_mesh: ImmediateMesh = mesh_instance.mesh
	immediate_mesh.clear_surfaces()
	
	var laser_end: Vector3
	if ray_cast.is_colliding():
		laser_end = to_local(ray_cast.get_collision_point())
	else:
		laser_end = Vector3(max_range, 0.0, 0.0)
		
	var spread_offset = _current_spread * max_spread
	# draws line from muzzle to laser endpoint
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	# main laser
	immediate_mesh.surface_set_color(laser_color)
	immediate_mesh.surface_add_vertex(Vector3.ZERO)		# muzzle position (local origin)
	immediate_mesh.surface_set_color(laser_color)
	immediate_mesh.surface_add_vertex(laser_end)		# collision point or max range
	# converging laser top side
	immediate_mesh.surface_set_color(spread_color)
	immediate_mesh.surface_add_vertex(Vector3.ZERO)
	immediate_mesh.surface_set_color(spread_color)
	var side_end = Vector3(minf(laser_end.x, side_laser_length), 0.0, 0.0)
	immediate_mesh.surface_add_vertex(side_end + Vector3(0.0, spread_offset, 0.0))
	#converging laser bottom side
	immediate_mesh.surface_set_color(spread_color)
	immediate_mesh.surface_add_vertex(Vector3.ZERO)
	immediate_mesh.surface_set_color(spread_color)
	immediate_mesh.surface_add_vertex(side_end - Vector3(0.0, spread_offset, 0.0))
	
	immediate_mesh.surface_end()
	
	# pie slice mesh
	var fill_color = Color(spread_color, fill_alpha)
	var angle_up = atan2(spread_offset, side_laser_length)
	var angle_down = -angle_up
	var radius = sqrt(side_laser_length * side_laser_length + spread_offset * spread_offset)
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(pie_slices):
		var angle_a = lerpf(angle_up, angle_down, float(i) / pie_slices)
		var angle_b = lerpf(angle_up, angle_down, float(i + 1) / pie_slices)
		
		var point_a = Vector3(
			cos(angle_a) * radius,
			sin(angle_a) * radius,
			0.0
		)
		var point_b = Vector3(
			cos(angle_b) * radius,
			sin(angle_b) * radius,
			0.0
		)
		
		immediate_mesh.surface_set_color(fill_color)
		immediate_mesh.surface_add_vertex(Vector3.ZERO)
		immediate_mesh.surface_set_color(fill_color)
		immediate_mesh.surface_add_vertex(point_a)
		immediate_mesh.surface_set_color(fill_color)
		immediate_mesh.surface_add_vertex(point_b)
		
	immediate_mesh.surface_end()
	## BEAM
	if _beam_active:
		var beam_mesh: ImmediateMesh = beam_mesh_instance.mesh
		beam_mesh.clear_surfaces()
		var beam_end_local = to_local(_beam_end)
		var beam_dir = beam_end_local.normalized()
		var perp = Vector3(-beam_dir.y, beam_dir.x, 0.0) * (_beam_width * 0.5)
		# four corners of quad
		var top_start = perp
		var bot_start = -perp
		var top_end = beam_end_local + perp
		var bot_end = beam_end_local - perp
		
		beam_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
		# first triangle
		beam_mesh.surface_set_color(beam_color)
		beam_mesh.surface_add_vertex(top_start)
		beam_mesh.surface_set_color(beam_color)
		beam_mesh.surface_add_vertex(top_end)
		beam_mesh.surface_set_color(beam_color)
		beam_mesh.surface_add_vertex(bot_start)
		# second triangle
		beam_mesh.surface_set_color(beam_color)
		beam_mesh.surface_add_vertex(bot_start)
		beam_mesh.surface_set_color(beam_color)
		beam_mesh.surface_add_vertex(top_end)
		beam_mesh.surface_set_color(beam_color)
		beam_mesh.surface_add_vertex(bot_end)
		beam_mesh.surface_end()
	else:
		var beam_mesh: ImmediateMesh = beam_mesh_instance.mesh
		beam_mesh.clear_surfaces()
	
