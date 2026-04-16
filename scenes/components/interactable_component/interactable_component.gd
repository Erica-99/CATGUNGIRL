extends Node3D
@onready var interaction_range: Area3D = $"Interaction Range"
@onready var collision: CollisionShape3D = $"Interaction Range/CollisionShape3D"
@onready var dialogue_renderer: Sprite3D = $"Interaction Range/CollisionShape3D/DialogueRenderer"

@export var offset_x_amount: float = 0.0
@export var offset_y_amount: float = 0.0
@export var offset_z_amount: float = 0.0

var parent_reference
var player_reference
var player_in_range: bool = false
var mesh_size: Vector3

func _ready() -> void:
	parent_reference = get_parent()
	var parent_mesh_children = parent_reference.find_children("*", "MeshInstance3D", false)
	if parent_mesh_children.size() > 0:
		_calculate_interaction_zone(parent_mesh_children[0])

func _calculate_interaction_zone(child):
	# ts gave me an aneurism
	var mesh_box = child.get_aabb().size
	mesh_size = mesh_box
	
	var start_interaction_range: Vector3 = Vector3(child.global_position.x, child.global_position.y, 0)
	
	var distance_between: float = start_interaction_range.distance_to(child.global_position)
	
	mesh_box.x += distance_between
	mesh_box.y += offset_y_amount
	mesh_box.z += offset_z_amount
	
	collision.global_position = start_interaction_range
	
	collision.shape.size = mesh_box
	collision.rotation = child.rotation


func _process(delta: float) -> void:
	if player_in_range:
		var current_player_status = player_reference.input_component.get_input_state()
		#if current_player_status["interacting"]:
		#	dialogue_renderer.


func _on_interaction_range_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player_in_range = true
		player_reference = body
		dialogue_renderer._add_interact_bubble()


func _on_interaction_range_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player_in_range = false
		dialogue_renderer._remove_bubbles()
