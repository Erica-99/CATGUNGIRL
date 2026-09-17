extends Control

@onready var anim: AnimationPlayer = $TutorialAnims
@onready var title_label: RichTextLabel = $Content/MarginContainer/VBoxContainer/Title
@onready var description_label: RichTextLabel = $Content/MarginContainer/VBoxContainer/Description
@onready var task_label: RichTextLabel = $Content/MarginContainer/VBoxContainer/Task

var _pending_step: TutorialStep = null
var _displayed_step: TutorialStep = null
var _is_open: bool = false


func _ready() -> void:
	anim.play("Inactive")
	anim.animation_finished.connect(_on_anim_finished)
	TutorialManager.step_shown.connect(_on_step_shown)
	TutorialManager.sequence_finished.connect(_on_sequence_finished)
	InputDeviceManager.input_device_changed.connect(_on_input_device_changed)

func _on_step_shown(step: TutorialStep) -> void:
	if _is_open:
		_pending_step = step
		anim.play("Close")
	else:
		_display_step(step)

func _on_sequence_finished() -> void:
	_pending_step = null
	if _is_open:
		anim.play("Close")

func _on_input_device_changed(_using_controller: bool) -> void:
	if _displayed_step:
		description_label.text = _description_text_for(_displayed_step)

func _display_step(step: TutorialStep) -> void:
	_displayed_step = step
	title_label.text = step.title
	description_label.text = _description_text_for(step)
	task_label.text = step.task
	anim.play("Open")
	_is_open = true

func _description_text_for(step: TutorialStep) -> String:
	if not InputDeviceManager.is_using_controller():
		return step.description_kbm
	
	if InputDeviceManager.get_controller_family() == &"playstation" and step.description_playstation != "":
		return step.description_playstation
	
	if step.description_gamepad != "":
		return step.description_gamepad
	
	return step.description_kbm

func _on_anim_finished(anim_name: StringName) -> void:
	if anim_name != "Close":
		return
	
	_is_open = false
	_displayed_step = null
	anim.play("Inactive")
	
	if _pending_step:
		var step := _pending_step
		_pending_step = null
		_display_step(step)
