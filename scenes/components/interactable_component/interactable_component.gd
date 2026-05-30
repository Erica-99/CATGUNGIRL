extends Node3D
@onready var interaction_range: Area3D = $"Interaction Range"

@export var interactable_type: Enums.InteractableType = Enums.InteractableType.DOOR
@export var interactable_load_type: Enums.InteractableLoadType = Enums.InteractableLoadType.BACKGROUND
@export var interaction_distance: float = 4.0
@export var event_trigger: Node
@export var enabled: bool = true

var previously_triggered: bool = false

var player_in_range: bool = false
var mesh_size: Vector3
var tween: Tween
var initial_position: Vector3

var player_reference

# temp var
@export var require_interaction: bool = true

func _ready() -> void:
	_calculate_interaction_zone(interactable_load_type != Enums.InteractableLoadType.BACKGROUND_MESHINSTANCE)
	
	if interactable_type == Enums.InteractableType.BRAIN_TERMINAL:
		EventManager.shield_enabled_status.connect(_handle_brain_changes)

func _calculate_interaction_zone(is_using_obj_asset: bool = true):
	#https://forum.godotengine.org/t/is-there-a-way-to-get-the-size-of-a-3d-mesh/23154/3
	var mesh_box
	if get_parent() != null:
		mesh_box = get_parent().get_aabb().size
	
	var collision = CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	interaction_range.add_child(collision)
	
	if interactable_load_type == Enums.InteractableLoadType.BACKGROUND:
		collision.shape.size = Vector3(mesh_box.z, mesh_box.y, interaction_distance)
		collision.position = Vector3(0, mesh_box.y / 2, -interaction_distance / 2)
		
	elif interactable_load_type == Enums.InteractableLoadType.BACKGROUND_MESHINSTANCE:
		collision.shape.size = Vector3(interaction_distance, interaction_distance, interaction_distance)
		collision.position = Vector3(0, 0, interaction_distance / 2)
		
	elif interactable_load_type == Enums.InteractableLoadType.DOOR:
		collision.shape.size = Vector3(mesh_box.x + (interaction_distance / 3), mesh_box.y + (interaction_distance / 3), interaction_distance)


func _process(delta: float) -> void:
	if player_in_range && enabled:
		var current_player_status = player_reference.input_component.get_input_state()
		
		if interactable_type == Enums.InteractableType.DOOR:
			if require_interaction && current_player_status["interacting"]:
				_play_interact_animation("open")
		else:
			if current_player_status["interacting"]:
				if event_trigger != null:
					event_trigger._emit_signal()
					
					if event_trigger._one_shot:
						enabled = false
						EventManager.system_message.emit("", false)


func _play_interact_animation(animation_name: String) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	
	if animation_name == "open":
		tween.tween_property(get_parent().get_parent(), "position:x", initial_position.x - 10, 0.8)
	else:
		tween.tween_property(get_parent().get_parent(), "position:x", initial_position.x, 0.8)
	
func _on_interaction_range_body_entered(body: Node3D) -> void:
	if body.name == "Player" && enabled:
		player_in_range = true
		player_reference = body
		if require_interaction:
			EventManager.system_message.emit("Press E to interact.", true)
		else:
			if interactable_type == Enums.InteractableType.DOOR:
				_play_interact_animation("open")

func _on_interaction_range_body_exited(body: Node3D) -> void:
	if body.name == "Player" && enabled:
		player_in_range = false
		if interactable_type == Enums.InteractableType.DOOR:
			_play_interact_animation("close")
		EventManager.system_message.emit("", false)

func _handle_brain_changes(status: bool):
	if status && !previously_triggered:
		enabled = true
		previously_triggered = true
