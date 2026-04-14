extends Node3D
@onready var interaction_range: Area3D = $"Interaction Range"
@onready var collision_shape_3d: CollisionShape3D = $"Interaction Range/CollisionShape3D"

@export var offset_x_amount: float = 0.0
@export var offset_y_amount: float = 0.0
@export var offset_z_amount: float = 0.0

var parent_reference

func _ready() -> void:
	parent_reference = get_parent()
	var parent_mesh_children = parent_reference.find_children("*", "MeshInstance3D", false)
	if parent_mesh_children.size() > 0:
		var mesh_box = parent_mesh_children[0].get_aabb().size
		mesh_box.x += offset_x_amount
		mesh_box.y += offset_y_amount
		mesh_box.z += offset_z_amount
		
		collision_shape_3d.shape.size = mesh_box


func _process(delta: float) -> void:
	pass


func _on_interaction_range_body_entered(body: Node3D) -> void:
	print("PRESS E TO INTERACT")
