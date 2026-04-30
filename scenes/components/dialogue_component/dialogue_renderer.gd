extends Sprite3D
@onready var sub_viewport: SubViewport = $SubViewport
@onready var dialogue_component: Node = $SubViewport/DialogueComponent

# export vars
	# the elapsed time here will be removed to instead favor signals perchance
	# TODO: at a later stage
@export var min_dialogue_elapsed_time: float = 2.0
@export var max_dialogue_elapsed_time: float = 10.0
@export var can_speak: bool = true
@export var debug_mode: bool = false
@export var size_of_viewport: Vector2 = Vector2(500, 600)
@export var base_transparency_speed: float = 4.0

func _ready() -> void:
	sub_viewport.size = size_of_viewport
	position.z += 1
	rotation = get_parent().rotation
	

func _is_attached_to_entity() -> bool:
	if get_parent() is CharacterBody3D:
		return true
	return false
	
func _process(delta: float) -> void:
	pass
		
		
func _add_interact_bubble() -> void:
	dialogue_component._add_bubble("Press E to interact.", true)
	print(sub_viewport.size)
	
func _fade_bubbles() -> void:
	dialogue_component._make_all_bubbles_transparent()
