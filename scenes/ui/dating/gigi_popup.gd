extends BoxContainer

# references
@export var speaker_name: Label
@export var gigi_image: TextureRect
@export var gigi_dialogue: PanelContainer
@export var grid_container: GridContainer
@export var call_panel: PanelContainer

## You can change this to however long you want before the popup closes
var _delay = 5

var forced_dialogue_additional_delay = 0.5

# runtime vars
var popup_active = false
var current_popup_scene = []
var popup_dialogue = {}
var requires_option_selection = false

var dialogue_player_reference: AudioStreamPlayer

# consts
const SECONDS_PER_CHARACTER = 0.05
# I HATE NAMING VARIABLES IDK WHAT TO CALL THIS CONSTANT!?!??!
const LEEWAY_OF_TYPEWRITER = 0.8

# connect popup to event handler
func _ready() -> void:
	EventManager.connect("activate_popup", _on_activate_popup)

func _unhandled_input(event: InputEvent) -> void:
	if !requires_option_selection:
		return
	else:
		if event.is_action_pressed("ui_left"):
			_option_selected(popup_dialogue["options"][0])
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_right"):
			_option_selected(popup_dialogue["options"][1])
			get_viewport().set_input_as_handled()

# get values from JSON file via DialogueProcessor
func _popup_start(popup_id: String):
	visible = true
	popup_active = true
	current_popup_scene = DialogueProcessor._get_dating_scene(CustomResourceLoader.popup_dialogue_path + "gigi_popups", str(popup_id))
	popup_dialogue = DialogueProcessor._get_next_dating_dialogue(current_popup_scene)
	AudioManager.dialogue_ducking(true)
	_display()

# displays dialogue on screen
func _display():
	# failsafe
	if "dialogue" not in popup_dialogue.keys():
		_end_popup()
	
	# get delay via popup char count	
	_delay = SECONDS_PER_CHARACTER * popup_dialogue["dialogue"].length()
	# set text - additional params determine how it should display (as typewriter)
	gigi_dialogue._set_text(popup_dialogue["dialogue"], true, _delay * LEEWAY_OF_TYPEWRITER)
	# set speaker name and image
	speaker_name.text = popup_dialogue["origin"]
	gigi_image.texture = null
	if popup_dialogue["icon"] != "":
		gigi_image.texture = load(popup_dialogue["icon"])
		call_panel.visible = true
	else:
		call_panel.visible = false
	
	# play voice lines if any
	var voice_line = popup_dialogue["audio_file"]
	if voice_line != "":
		dialogue_player_reference = AudioManager.play_dialogue_file(voice_line)
	
	# Trigger event
	DialogueProcessor._check_and_trigger_dialogue_event(popup_dialogue)
	
	# generate buttons
	var options = popup_dialogue["options"]
	if options.size() > 0:
		requires_option_selection = true
		for option in options:
			var button = Button.new()
			# set button values
			button.text = option["option"]
			button.focus_mode = Control.FOCUS_NONE
			button.custom_minimum_size = Vector2(280, 100.0)
			button.autowrap_mode = TextServer.AUTOWRAP_WORD
			button.size_flags_vertical = Control.SIZE_EXPAND
			# connect to handler
			button.pressed.connect(_option_selected.bind(option))
			grid_container.add_child(button)
	else:
		# Simple way to make sure popup time matches voice clip
		# Use whichever is longer, sound_clip length or _delay
		if voice_line != "" and dialogue_player_reference != null:
			await get_tree().create_timer(
				maxf(
					dialogue_player_reference.stream.get_length(),
					_delay
				) + forced_dialogue_additional_delay
			).timeout
			_increment_date_stage(popup_dialogue)
		else:
			await get_tree().create_timer(_delay + 2).timeout
			_increment_date_stage(popup_dialogue)

func _option_selected(value: Dictionary):
	# delete buttons
	for button in grid_container.get_children():
		button.queue_free()
	# get dialogue from option selected
	_increment_date_stage(value)

func _increment_date_stage(value: Dictionary):
	requires_option_selection = false
	if value["next_id"] == "":
		_end_popup()
	else:
		# continue dating loop
		popup_dialogue = DialogueProcessor._get_next_dating_dialogue(current_popup_scene, value)
		_display()

func _end_popup():
	AudioManager.dialogue_ducking(false)
	popup_active = false
	visible = false

# Debug input
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("gigi_show"):
		#if not popup_active:
			#_popup_start(0)

func _on_activate_popup(popup_id: String) -> void:
	_popup_start(popup_id)
