extends Control

var isDating: bool
var date: Array
var line
var file
var dialogueID = "000001"
## This is for when there are 3 options instead of 2
var extraButton: Button

var permit_next := true

@onready var buttonContainer = $ButtonContainer
@onready var gigiImage = $gigi_pose
@onready var dialogue = $date_txt_bgd/date_txt

@export var filePath = "res://resources/dialogue/dates/date_1.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_dialogue()
	visible = false
	buttonContainer.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("date_show"):
		if not isDating:
			_date_start()
	if isDating && permit_next && event.is_action_pressed("next"):
		dialogueID = line["next_id"]
		if _check_dialogue_end():
			_close_date()
		else:
			_set_ui()

func _date_start():
	visible = true
	isDating = true
	_set_ui()

func _load_dialogue():
	file = FileAccess.get_file_as_string(filePath)
	var json = JSON.new()
	json.parse(file)
	date = json.data["date_1"]

func _get_dialogue_by_id(id):
	for line in date:
		if line["id"] == id:
			return line
	return null

func _set_ui():
	line = _get_dialogue_by_id(dialogueID)
	_check_has_options()
	_load_image()
	_set_dialogue()

func _check_dialogue_end() -> bool:
	if dialogueID == "":
		return true
	else:
		return false

func _close_date():
	isDating = false
	dialogueID = "000001"
	permit_next = false
	await get_tree().create_timer(1.0).timeout
	visible = false

func _check_has_options():
	if line["has_options"] == true:
		permit_next = false
		buttonContainer.visible = true
		var buttons = buttonContainer.get_children()
		for i in range(line["options"].size()):
			var button = Button.new()
			button.text = line["options"][i]["option"]
			button.custom_minimum_size = Vector2(300.0, 100.0)
			button.pressed.connect(_option_selected.bind(i))
			buttonContainer.add_child(button)
	else:
		permit_next = true

func _load_image():
	var path = line["icon"]
	var image = load(path)
	gigiImage.texture = image

func _set_dialogue():
	dialogue.text = line["dialogue"]

func _option_selected(index):
	buttonContainer.visible = false
	dialogueID = line["options"][index]["next_id"]
	for i in buttonContainer.get_children():
			i.queue_free()
	if _check_dialogue_end():
		_close_date()
	else:
		_set_ui()
