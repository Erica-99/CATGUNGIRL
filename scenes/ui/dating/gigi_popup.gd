extends BoxContainer

# references
@onready var speaker_name: Label = $HBoxContainer/VBoxContainer/SpeakerName
@onready var gigi_image: TextureRect = $HBoxContainer/gigi_image
@onready var gigi_dialogue: PanelContainer = $HBoxContainer/VBoxContainer/DialogueBubble
@onready var grid_container: GridContainer = $HBoxContainer/VBoxContainer/GridContainer

## You can change this to however long you want before the popup closes
var _delay = 5

var forced_dialogue_additional_delay = 0.5

# Check when dialogue is playing so that if a new one starts it skips through and begins the new one
var dialogue_playing: bool = false
var dialogue_skip: bool = false
var dialogue_playtime: float = 0
var dialogue_length: float = 999
signal dialogue_skip_finished

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
	EventManager.connect("player_health_changed", _on_player_health_changed)

func _process(delta: float) -> void:
	if dialogue_playing:
		dialogue_playtime += delta
		if dialogue_playtime > dialogue_length:
			dialogue_playtime = 0
			_increment_date_stage(popup_dialogue)

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
	# When there isn't currently any dialogue playing, display normally
	if !dialogue_playing:
		visible = true
		popup_active = true
		current_popup_scene = DialogueProcessor._get_dating_scene(CustomResourceLoader.popup_dialogue_path + "gigi_popups", str(popup_id))
		popup_dialogue = DialogueProcessor._get_next_dating_dialogue(current_popup_scene)
		AudioManager.dialogue_ducking(true)
		dialogue_playing = true
		_display()
	# If dialogue is currently playing, skip through it and wait for it to "finish" before playing
	else:
		_skip_currently_playing_dialogue()
		await dialogue_skip_finished
		_popup_start(popup_id)
		

# displays dialogue on screen
func _display():
	# failsafe
	if "dialogue" not in popup_dialogue.keys():
		print("failsafe end_popup")
		_end_popup()
	
	# When not skipping dialogue plays normally
	if !dialogue_skip:
		# get delay via popup char count	
		_delay = SECONDS_PER_CHARACTER * popup_dialogue["dialogue"].length()
		# set text - additional params determine how it should display (as typewriter)
		gigi_dialogue._set_text(popup_dialogue["dialogue"], true, _delay * LEEWAY_OF_TYPEWRITER)
		# set speaker name and image
		speaker_name.text = popup_dialogue["origin"]
		gigi_image.texture = null
		if popup_dialogue["icon"] != "":
			gigi_image.texture = load(popup_dialogue["icon"])
		
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
				dialogue_length = (
					maxf(
						dialogue_player_reference.stream.get_length(),
						_delay
					) + forced_dialogue_additional_delay
				)
			else:
				dialogue_length = (_delay + forced_dialogue_additional_delay)
	# When skipping, increment date_stages without displaying/playing audio
	else:
		DialogueProcessor._check_and_trigger_dialogue_event(popup_dialogue)
		_increment_date_stage(popup_dialogue)

# Skips the current active dialogue
func _skip_currently_playing_dialogue():
	if dialogue_playing:
		# Activates skip
		dialogue_skip = true
		# Stop audio
		dialogue_player_reference.stop()
		# Kill typewriter tween (otherwise next dialogue starts partway typed)
		gigi_dialogue._kill_tween()
		# Max out dialogue playtime to move to next dialogue
		dialogue_playtime = 999

func _on_player_health_changed(_old_health, new_health, _damage_or_heal_instance):
	if new_health <= 0:
		_skip_currently_playing_dialogue()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_skip_dialogue"):
		if dialogue_playing:
			print("Debug: dialogue skip")
			_skip_currently_playing_dialogue()

func _option_selected(value: Dictionary):
	# delete buttons
	for button in grid_container.get_children():
		button.queue_free()
	# get dialogue from option selected
	_increment_date_stage(value)

func _increment_date_stage(value: Dictionary):
	requires_option_selection = false
	if value["next_id"] == "":
		print("Next id is '', _end_popup called")
		_end_popup()
	else:
		# continue dating loop
		popup_dialogue = DialogueProcessor._get_next_dating_dialogue(current_popup_scene, value)
		_display()

func _end_popup():
	AudioManager.dialogue_ducking(false)
	popup_active = false
	visible = false
	dialogue_playing = false
	if dialogue_skip:
		dialogue_skip = false
		dialogue_skip_finished.emit()
	print("Dialogue ended: playing: " + str(dialogue_playing) + ", skipped: " + str(dialogue_skip))

# Debug input
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("gigi_show"):
		#if not popup_active:
			#_popup_start(0)

func _on_activate_popup(popup_id: String) -> void:
	_popup_start(popup_id)
