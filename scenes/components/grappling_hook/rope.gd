extends MeshInstance3D

@export var point_a: Vector3
@export var point_b: Vector3

@export var thickness: float = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_points(a: Vector3, b: Vector3) -> void:
	point_a = a
	point_b = b
	
	var mesh_instance = mesh
	mesh_instance.clear_surfaces()
	
	var direction = (point_b - point_a).normalized()
	var up = Vector3(0, 0, -1)
	var side = direction.cross(up).normalized() * (thickness / 2.0)
	
	var vertex_1 = point_a - side
	var vertex_2 = point_a + side
	var vertex_3 = point_b + side
	var vertex_4 = point_b - side
	
	mesh_instance.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Triangle 1
	mesh_instance.surface_add_vertex(vertex_1)
	mesh_instance.surface_add_vertex(vertex_2)
	mesh_instance.surface_add_vertex(vertex_3)
	
	# Triangle 2
	mesh_instance.surface_add_vertex(vertex_1)
	mesh_instance.surface_add_vertex(vertex_3)
	mesh_instance.surface_add_vertex(vertex_4)
	
	mesh_instance.surface_end()
