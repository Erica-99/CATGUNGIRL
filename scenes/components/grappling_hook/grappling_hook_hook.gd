extends Node3D

@export var hook_anchor: Vector3 = Vector3(0, 0, 0)
@export var gun_anchor: Vector3 = Vector3(0, 0, 0)

@onready var rope: MeshInstance3D = $Rope

func _ready() -> void:
	hook_anchor = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mesh_instance := rope.mesh as ImmediateMesh
	mesh_instance.clear_surfaces()
	
	mesh_instance.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh_instance.surface_add_vertex(hook_anchor)
	mesh_instance.surface_add_vertex(gun_anchor)
	mesh_instance.surface_end()

func _physics_process(delta: float) -> void:
	hook_anchor = position
