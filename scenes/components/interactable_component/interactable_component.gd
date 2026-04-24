extends Node3D
@onready var interaction_range: Area3D = $"Interaction Range"
@onready var dialogue_renderer: Sprite3D = $"Interaction Range/DialogueRenderer"

@export var interactable_type: Enums.InteractableType = Enums.InteractableType.DOOR
@export var interaction_distance: float = 3.0

var parent_reference
var player_reference
var player_in_range: bool = false
var mesh_size: Vector3
var tween: Tween
var initial_position: Vector3

# temp var
var door_must_be_interacted_with: bool = true

func _ready() -> void:
	parent_reference = get_parent()
	initial_position = parent_reference.position
	var parent_mesh_children = parent_reference.find_children("*", "MeshInstance3D", false)
	if parent_mesh_children.size() > 0:
		_calculate_interaction_zone(parent_mesh_children[0], false)

func _calculate_interaction_zone(child, is_centred):
	#https://forum.godotengine.org/t/is-there-a-way-to-get-the-size-of-a-3d-mesh/23154/3
	var mesh_box = child.get_aabb().size
	
	var collision = CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	interaction_range.add_child(collision)
	#collision.shape.size = mesh_box
	
	if interactable_type == Enums.InteractableType.CONSOLE:
		# old shit remove later
		#var start_interaction_range: Vector3 = Vector3(child.global_position.x, child.global_position.y, child.global_position.z)
		#var distance_between: float = start_interaction_range.distance_to(child.global_position)
		#mesh_box.x += distance_between
		#mesh_box.y += offset_y_amount
		#mesh_box.z += offset_z_amount
		#var offsets = Vector3(offset_x_amount, offset_y_amount, distance_between)
		#collision.shape.size += offsets
		
		collision.shape.size = Vector3(mesh_box.z, mesh_box.y, interaction_distance)
		collision.position = Vector3(0, 0, interaction_distance / 2)
	else:
		collision.shape.size = Vector3(mesh_box.x + (interaction_distance / 3), mesh_box.y + (interaction_distance / 3), interaction_distance)
		#collision.position = Vector3(0, 0, interaction_distance / 2)
		#var offsets = Vector3(1, 1, 1)
		#collision.shape.size = offsets
	
	#collision.rotation = child.rotation


func _process(delta: float) -> void:
	if player_in_range:
		var current_player_status = player_reference.input_component.get_input_state()
		
		if interactable_type == Enums.InteractableType.DOOR:
			if door_must_be_interacted_with && current_player_status["interacting"]:
				_play_interact_animation("open")
		else:
			if current_player_status["interacting"]:
				print("interacting with console")

func _play_interact_animation(animation_name: String) -> void:
	# tried to do this without tweening but its not possible unless we alter the objects :(
	#https://docs.godotengine.org/en/stable/classes/class_tween.html
	if tween:
		tween.kill()
	tween = create_tween()
	
	if animation_name == "open":
		tween.tween_property(get_parent(), "position", initial_position + Vector3(-1.5, 0, 0), 0.8)
		pass
	else:
		tween.tween_property(get_parent(), "position", initial_position, 0.8)
		pass
	
	# old code
	#var animation_player = parent_reference.find_child("AnimationPlayer", false)
	#if animation_player != null:
	#	if animation_player.has_animation(animation_name):
	#		animation_player.play(animation_name)
		

func _on_interaction_range_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player_in_range = true
		player_reference = body
		if interactable_type == Enums.InteractableType.DOOR && not door_must_be_interacted_with:
			_play_interact_animation("open")
		#dialogue_renderer._add_interact_bubble()


func _on_interaction_range_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player_in_range = false
		if interactable_type == Enums.InteractableType.DOOR:
			_play_interact_animation("close")
		#dialogue_renderer._remove_bubbles()
