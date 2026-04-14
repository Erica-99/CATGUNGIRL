extends Control

## Variables for loading different dialogue options
var _onDate = false
var _dialogue_loaded
var _dialogue_id = "001"

## Gigi's variables that will be changed
@onready var _gigi_text = $GigiDialogue/gigi_txt_bgd/gigi_txt
@onready var _gigi_image = $GigiImage/gigi_image
@onready var _gigi_opt1 = $GigiDialogue/btn_optA
@onready var _gigi_opt2 = $GigiDialogue/btn_optB

func _ready() -> void:
	## Hide the UI once game begins
	visible = false
	## Read file on game start
	_load_dialogue()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("gigi_show"):
	## Toggle the UI using 'G' key
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
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _load_dialogue():
	## Load the .json file into an array
	var file = FileAccess.get_file_as_string("res://resources/dialogue/gigi_popup.json")
	var loader = JSON.new()
	loader.parse(file)
	_dialogue_loaded = loader.data["interactions"]
	print("DIALOGUE LOADED")

func _fetch_dialogue_by_id(id):
	for line in _dialogue_loaded:
		if line["id"] == id:
			print(id, " has been called")
			return line
	return null
	
func _set_gigi():
	var interact = _fetch_dialogue_by_id(_dialogue_id)
	print("Interact is:", interact)
	_gigi_text.text = interact.get("dialogue")
	_load_image(interact)
	_set_btn_text(interact)
	
func _load_image(dict):
	var path = dict.get("image")
	var image = load(path)
	_gigi_image.texture = image

func _set_btn_text(dict):
	var options = dict.get("options", [])
	_gigi_opt1.text = options[0]["option1"]
	_gigi_opt2.text = options[1]["option2"]
