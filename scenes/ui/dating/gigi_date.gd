extends Control

# references
@onready var button_container: HBoxContainer = $date_txt_bgd/ButtonContainer
@onready var gigi_image = $gigi_pose
@onready var dialogue = $date_txt_bgd/date_txt
@onready var dialogue_bubble: PanelContainer = $date_txt_bgd/DialogueBubble
@onready var press_button_info: RichTextLabel = $"date_txt_bgd/Press Button Info"

# determines whether dating screen should be visible or not
var dating_active: bool = false

# determines if button must be clicked to proceed
var requires_option_selection: bool = false

# current whole dating scene
var current_dating_scene: Array = []

# current dialogue section of scene
var dating_dialogue: Dictionary = {}

# amount of seconds till typewriter finished 
# (on finish then buttons + text appears to inform player to press to go to next screen)
var typewriter_delay: float = 0

# holds info on whether typewriter is writing out or not
var currently_writing = false

var writing_timer: Timer = Timer.new()

const SECONDS_PER_CHARACTER = 0.05

func _ready() -> void:
	EventManager.connect("activate_date", _on_activate_date)
	writing_timer.one_shot = true
	writing_timer.timeout.connect(_display_button_press_info)
	add_child(writing_timer)

# debug show dating
# TODO: move to player input component as an input state?
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("date_show"):
		if dating_active:
			if not requires_option_selection && not currently_writing:
				_increment_date_stage(dating_dialogue)
				return
				
			# end dialogue display early
			if currently_writing:
				currently_writing = false
				dialogue_bubble._kill_tween()
				# reset text (done to stop the shaking)
				dialogue_bubble._set_text(dating_dialogue["dialogue"])
				writing_timer.stop()
				_display_button_press_info()
		else:
			_date_start(0)

# set values for started date and retrieve scene and dialogue
# TODO: im just thinking but we could probably remove dating_active and favour 'visibility' as
	# our conditional var. this will sacrifice a bit of readability though lmfao idk
func _date_start(date_id: int):
	visible = true
	dating_active = true
	current_dating_scene = DialogueProcessor._get_dating_scene(CustomResourceLoader.dating_dialogue_path + "date_" + str(date_id), "date_" + str(date_id))
	dating_dialogue = DialogueProcessor._get_next_dating_dialogue(current_dating_scene)
	_display()

# display scene (fill out with info from current dating_dialogue)
func _display():
	press_button_info.visible = false
	button_container.visible = false
	# get delay via popup char count
	typewriter_delay = SECONDS_PER_CHARACTER * dating_dialogue["dialogue"].length()
	# set text - additional params determine how it should display (as typewriter)
	dialogue_bubble._set_text(dating_dialogue["dialogue"], true, typewriter_delay)
	currently_writing = true
	
	# temp timer
	writing_timer.wait_time = typewriter_delay + 0.5
	writing_timer.start()
	
	# set texture
	gigi_image.texture = load(dating_dialogue["icon"])
	
	# generate buttons
	var options = dating_dialogue["options"]
	if options.size() > 0:
		requires_option_selection = true
		for option in options:
			var button = Button.new()
			# set button values
			button.text = option["option"]
			button.custom_minimum_size = Vector2(300.0, 100.0)
			# connect to handler
			button.pressed.connect(_option_selected.bind(option))
			button_container.add_child(button)

func _display_button_press_info():
	currently_writing = false
	if dating_dialogue["options"].size() == 0:
		var tween = create_tween()
		tween.tween_property(press_button_info, "visible", true, 1)
	button_container.visible = true
	pass


# ends the current date (returns player to active world)
func _end_date():
	dating_active = false
	await get_tree().create_timer(0.5).timeout
	visible = false

# option click handler event
func _option_selected(value: Dictionary):
	# delete buttons
	for button in button_container.get_children():
		button.queue_free()
	# get dialogue from option selected
	_increment_date_stage(value)
	
# go to next dating dialogue line
func _increment_date_stage(value: Dictionary):
	requires_option_selection = false
	if value["next_id"] == "":
		_end_date()
	else:
		# continue dating loop
		dating_dialogue = DialogueProcessor._get_next_dating_dialogue(current_dating_scene, value)
		_display()

func _on_activate_date(date_id: int) -> void:
	_date_start(date_id)
