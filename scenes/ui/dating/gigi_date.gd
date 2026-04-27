extends Control

var dating_active: bool
var date_id: int = 0
var current_dating_scene = []
var dating_dialogue = {}
var requires_option_selection: bool = false

@onready var buttonContainer = $ButtonContainer
@onready var gigiImage = $gigi_pose
@onready var dialogue = $date_txt_bgd/date_txt

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("date_show"):
		if dating_active:
			if not requires_option_selection:
				_increment_date_stage(dating_dialogue)
		else:
			_date_start()

func _date_start():
	visible = true
	dating_active = true
	current_dating_scene = DialogueProcessor._get_dating_scene("date_" + str(date_id), "date_" + str(date_id))
	dating_dialogue = DialogueProcessor._get_next_dating_dialogue(current_dating_scene)
	_display()

func _display():
	dialogue.text = dating_dialogue["dialogue"]
	gigiImage.texture = load(dating_dialogue["icon"])
	
	var options = dating_dialogue["options"]
	if options.size() > 0:
		requires_option_selection = true
		for option in options:
			var button = Button.new()
			button.text = option["option"]
			button.custom_minimum_size = Vector2(300.0, 100.0)
			button.pressed.connect(_option_selected.bind(option))
			buttonContainer.add_child(button)

func _close_date():
	dating_active = false
	# DATE ID WOULD BE INCREMENTED - but for testing sake it has not been...
	# TODO: create additional date dialogues then increment here
	date_id = 0
	await get_tree().create_timer(1.0).timeout
	visible = false

func _option_selected(value: Dictionary):
	for i in buttonContainer.get_children():
		i.queue_free()
	_increment_date_stage(value)
	
func _increment_date_stage(value: Dictionary):
	requires_option_selection = false
	if value["next_id"] == "":
		_close_date()
	else:
		dating_dialogue = DialogueProcessor._get_next_dating_dialogue(current_dating_scene, value)
		_display()
