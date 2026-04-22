extends Control

## Variables for loading different dialogue options
var _onDate = false
var _dialogue_loaded
var _options
var _dialogue_id = "001"
var _delay = 3

## Gigi's variables that will be changed
@onready var _gigi_text = $GigiDialogue/gigi_txt_bgd/gigi_txt
@onready var _gigi_image = $GigiImage/gigi_image
@onready var _gigi_opt1: Button = $GigiDialogue/btn_optA
@onready var _gigi_opt2: Button = $GigiDialogue/btn_optB

func _ready() -> void:
	## Hide the UI once game begins
	visible = false
	## Read file on game start
	_load_dialogue()
	## Allow the button presses to be read
	_gigi_opt1.connect("pressed", _option1_pressed, CONNECT_PERSIST)
	_gigi_opt2.connect("pressed", _option2_pressed, CONNECT_PERSIST)
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("gigi_show"):
	## Toggle the UI using 'G' key
		print("G has been pressed!")
		_onDate = !_onDate
		if _onDate:
			_date_begin()
		else:
			_date_close()
	

## Make UI visible and show mouse
func _date_begin():
	visible = true
	_set_gigi()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

## Hide UI and hide mouse (position can still be tracked)
func  _date_close():
	visible = false
	_onDate = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _load_dialogue():
	## Load the .json file into an array
	var file = FileAccess.get_file_as_string("res://resources/dialogue/gigi_popup.json")
	var json = JSON.new()
	json.parse(file)
	_dialogue_loaded = json.data["interactions"]
	print("DIALOGUE LOADED")

func _fetch_dialogue_by_id(id):
	## Finds the dialogue sequence by id
	for line in _dialogue_loaded:
		if line["id"] == id:
			print(id, " has been called")
			return line
	return null
	
func _set_gigi():
	## Sets the UI to displayed the loaded interaction
	var interact = _fetch_dialogue_by_id(_dialogue_id)
	_options = interact.get("options", [])
	_gigi_text.text = interact.get("dialogue")
	_load_image(interact)
	_set_btn_text(interact)
	_gigi_opt1.visible = true
	_gigi_opt2.visible = true
	
func _load_image(dict):
	##Gets the file path of the image and displays
	var path = dict.get("image")
	var image = load(path)
	_gigi_image.texture = image

func _set_btn_text(dict):
	## Set the text of the buttons
	_gigi_opt1.text = _options[0]["dialogue"]
	_gigi_opt2.text = _options[1]["dialogue"]

func _option1_pressed():
	## Set the image and the text for the specific option chosen
	_gigi_opt1.visible = false
	_gigi_opt2.visible = false
	_gigi_text.text = _options[0]["response"]
	_load_image(_options[0])
	_dialogue_id = _options[0]["next_id"]
	## Wait 3 seconds, then UI disappears
	await get_tree().create_timer(_delay).timeout
	_date_close()

func _option2_pressed():
	## Set the image and the text for the specific option chosen
	_gigi_opt1.visible = false
	_gigi_opt2.visible = false
	_gigi_text.text = _options[1]["response"]
	_load_image(_options[1])
	_dialogue_id = _options[1]["next_id"]
	## Wait 3 seconds, then UI disappears
	await get_tree().create_timer(_delay).timeout
	_date_close()
