extends Node3D

## laser sight

@export var max_range: float = 40.0			# max laser length if nothing is hit
@export var laser_color: Color = Color.RED	# can change in inspector

@onready var ray_cast: RayCast3D = $RayCast3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	ray_cast.target_position = Vector3(max_range, 0.0, 0.0)
	mesh_instance.mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = laser_color
	mesh_instance.material_override = material

func _process(_delta: float) -> void:
	_draw_laser()

func _draw_laser() -> void:
	var immediate_mesh: ImmediateMesh = mesh_instance.mesh
	immediate_mesh.clear_surfaces()
	# if the raycast hits something, use the collision point
	# if nothing is hit, extend to max range along the forward axis
	var laser_end: Vector3
	if ray_cast.is_colliding():
		laser_end = to_local(ray_cast.get_collision_point())
	else:
		laser_end = Vector3(max_range, 0.0, 0.0)
	# draws line from muzzle to laser endpoint
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	immediate_mesh.surface_set_color(laser_color)
	immediate_mesh.surface_add_vertex(Vector3.ZERO)		# muzzle position (local origin)
	immediate_mesh.surface_set_color(laser_color)
	immediate_mesh.surface_add_vertex(laser_end)		# collision point or max range
	immediate_mesh.surface_end()
	
