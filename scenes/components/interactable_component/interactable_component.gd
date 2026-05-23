extends Node3D
@onready var interaction_range: Area3D = $"Interaction Range"

@export var interactable_type: Enums.InteractableType = Enums.InteractableType.DOOR
@export var interactable_load_type: Enums.InteractableLoadType = Enums.InteractableLoadType.BACKGROUND
@export var interaction_distance: float = 3.0
@export var event_trigger: Node

var player_in_range: bool = false
var mesh_size: Vector3
var tween: Tween
var initial_position: Vector3

var player_reference

# temp var
@export var require_interaction: bool = true

func _ready() -> void:
	if interactable_load_type != Enums.InteractableLoadType.BACKGROUND_MESHINSTANCE:
		_calculate_interaction_zone(true, get_parent())
	else:
		_calculate_interaction_zone(false)

func _calculate_interaction_zone(is_using_obj_asset: bool = true, parent: MeshInstance3D = null):
	#https://forum.godotengine.org/t/is-there-a-way-to-get-the-size-of-a-3d-mesh/23154/3
	var mesh_box
	if parent != null:
		mesh_box = parent.get_aabb().size
	
	var collision = CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	interaction_range.add_child(collision)
	
	if interactable_load_type == Enums.InteractableLoadType.BACKGROUND:
		collision.shape.size = Vector3(mesh_box.z, mesh_box.y, interaction_distance)
		collision.position = Vector3(0, 0, interaction_distance / 2)
		
	elif interactable_load_type == Enums.InteractableLoadType.BACKGROUND_MESHINSTANCE:
		collision.shape.size = Vector3(interaction_distance, interaction_distance, interaction_distance)
		collision.position = Vector3(0, 0, interaction_distance / 2)
		
	elif interactable_load_type == Enums.InteractableLoadType.DOOR:
		collision.shape.size = Vector3(mesh_box.x + (interaction_distance / 3), mesh_box.y + (interaction_distance / 3), interaction_distance)


func _process(delta: float) -> void:
	if player_in_range:
		var current_player_status = player_reference.input_component.get_input_state()
		
		if interactable_type == Enums.InteractableType.DOOR:
			if require_interaction && current_player_status["interacting"]:
				_play_interact_animation("open")
		else:
			if current_player_status["interacting"]:
				if event_trigger != null:
					event_trigger._emit_signal()

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
	
func _on_interaction_range_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player_in_range = true
		player_reference = body
		if interactable_type == Enums.InteractableType.DOOR:
			if require_interaction:
				EventManager.system_message.emit("Press E to interact.", true)
			
			else:
				_play_interact_animation("open")
	
		
		if interactable_type == Enums.InteractableType.CONSOLE || interactable_type == Enums.InteractableType.ELEVATOR:
			EventManager.system_message.emit("Press E to interact.", true)


func _on_interaction_range_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player_in_range = false
		if interactable_type == Enums.InteractableType.DOOR:
			_play_interact_animation("close")
		EventManager.system_message.emit("", false)
