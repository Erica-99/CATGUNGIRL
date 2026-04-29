extends BoxContainer

# references
@onready var gigi_image: TextureRect = $VBoxContainer/gigi_image
@onready var gigi_dialogue: PanelContainer = $VBoxContainer/DialogueBubble
@onready var grid_container: GridContainer = $VBoxContainer/GridContainer

## You can change this to however long you want before the popup closes
var _delay = 2

# runtime vars
var popup_active = false
var current_popup_scene = []
var popup_dialogue = {}
var requires_option_selection = false

# consts
const SECONDS_PER_CHARACTER = 0.05
# I HATE NAMING VARIABLES IDK WHGAT TO CALL THIS FUCKASS CONSTANT!?!??!
const LEEWAY_OF_TYPEWRITER = 0.8

# connect popup to event handler
func _ready() -> void:
	EventManager.connect("activate_popup", _on_activate_popup)

# get values from JSON file via DialogueProcessor
func _popup_start(popup_id: int):
	visible = true
	popup_active = true
	current_popup_scene = DialogueProcessor._get_dating_scene(CustomResourceLoader.popup_dialogue_path + "gigi_popups", "sequence_" + str(popup_id))
	popup_dialogue = DialogueProcessor._get_next_dating_dialogue(current_popup_scene)
	_display()

# displays dialogue on screen
func _display():
	# get delay via popup char count
	_delay = SECONDS_PER_CHARACTER * popup_dialogue["dialogue"].length()
	# set text - additional params determine how it should display (as typewriter)
	gigi_dialogue._set_text(popup_dialogue["dialogue"], true, _delay * LEEWAY_OF_TYPEWRITER)
	gigi_image.texture = load(popup_dialogue["icon"])
	
	# generate buttons
	var options = popup_dialogue["options"]
	if options.size() > 0:
		requires_option_selection = true
		for option in options:
			var button = Button.new()
			# set button values
			button.text = option["option"]
			button.custom_minimum_size = Vector2(140.0, 50.0)
			button.autowrap_mode = TextServer.AUTOWRAP_WORD
			button.size_flags_vertical = Control.SIZE_EXPAND
			# connect to handler
			button.pressed.connect(_option_selected.bind(option))
			grid_container.add_child(button)
	else:
		await get_tree().create_timer(_delay).timeout
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
	popup_active = false
	visible = false

# Debug input
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("gigi_show"):
		if not popup_active:
			_popup_start(0)

func _on_activate_popup(popup_id: int) -> void:
	_popup_start(popup_id)
