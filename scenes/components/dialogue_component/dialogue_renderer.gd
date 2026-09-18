extends Node3D

class_name DialogueRenderer

@onready var sub_viewport: SubViewport = $SubViewport
@onready var dialogue_component: VBoxContainer = $SubViewport/DialogueComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# export vars
	# the elapsed time here will be removed to instead favor signals perchance
	# TODO: at a later stage
@export var min_dialogue_elapsed_time: float = 2.0
@export var max_dialogue_elapsed_time: float = 10.0
@export var can_speak: bool = true
@export var debug_mode: bool = false
@export var size_of_viewport: Vector2 = Vector2(500, 600)
@export var base_transparency_speed: float = 4.0

@export var is_system_interact: bool = false

const KEYBOARD_INTERACT_PROMPT: String = "Press [img height=80]res://art/UI/Glyphs/KBM/Dark/E_Key_Dark.png[/img] to interact."
const XBOX_INTERACT_PROMPT: String = "Press [img height=80]res://art/UI/Glyphs/Xbox/XboxSeriesX_X.png[/img] to interact."
const PLAYSTATION_INTERACT_PROMPT: String = "Press [img height=80]res://art/UI/Glyphs/PS5/PS5_Square.png[/img] to interact."

var prompt_mapping: Dictionary = {
	"keyboard": KEYBOARD_INTERACT_PROMPT,
	"xbox": XBOX_INTERACT_PROMPT,
	"playstation": PLAYSTATION_INTERACT_PROMPT,
}

var interact_string = KEYBOARD_INTERACT_PROMPT

func _ready() -> void:
	sub_viewport.size = size_of_viewport
	position.z += 1
	rotation = get_parent().rotation
	EventManager.controller_status.connect(_update_interact_string)
	

func _update_interact_string(controller_type: String) -> void:
	interact_string = prompt_mapping[controller_type]
	
	dialogue_component._update_bubble_text(interact_string)

func _is_attached_to_entity() -> bool:
	if get_parent() is CharacterBody3D:
		return true
	return false
	
func _process(delta: float) -> void:
	pass
		
		
func _add_interact_bubble() -> void:
	dialogue_component._add_bubble(interact_string, true)
	#print(sub_viewport.size)
	
func _fade_bubbles() -> void:
	dialogue_component._make_all_bubbles_transparent()

func _interact_animation() -> void:
	animation_player.play("selected")
