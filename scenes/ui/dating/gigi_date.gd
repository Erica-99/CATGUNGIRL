extends Control

# references
@onready var button_container = $ButtonContainer
@onready var gigi_image = $gigi_pose
@onready var dialogue = $date_txt_bgd/date_txt

# determines whether dating screen should be visible or not
var dating_active: bool = false

# determines if button must be clicked to proceed
var requires_option_selection: bool = false

# holds reference to current dating progression (each index is one whole dating scene)
var date_id: int = 0

# current whole dating scene
var current_dating_scene: Array = []

# current dialogue section of scene
var dating_dialogue: Dictionary = {}


# ready unused (values which were initialised here have been moved elsewhere)
func _ready() -> void:
	pass

# handle date show event
# TODO: move to player input component as an input state?
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("date_show"):
		if dating_active:
			if not requires_option_selection:
				_increment_date_stage(dating_dialogue)
		else:
			_date_start()

# set values for started date and retrieve scene and dialogue
# TODO: im just thinking but we could probably remove dating_active and favour 'visibility' as
	# our conditional var. this will sacrifice a bit of readability though lmfao idk
func _date_start():
	visible = true
	dating_active = true
	current_dating_scene = DialogueProcessor._get_dating_scene("date_" + str(date_id), "date_" + str(date_id))
	dating_dialogue = DialogueProcessor._get_next_dating_dialogue(current_dating_scene)
	_display()

# display scene (fill out with info from current dating_dialogue)
func _display():
	# set text and images
	dialogue.text = dating_dialogue["dialogue"]
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

# ends the current date (returns player to active world)
func _end_date():
	dating_active = false
	# DATE ID WOULD BE INCREMENTED - but for testing sake it has not been...
	# TODO: create additional date dialogues then increment here
	date_id = 0
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
