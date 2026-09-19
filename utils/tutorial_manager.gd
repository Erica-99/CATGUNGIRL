extends Node

signal step_shown(step: TutorialStep)
signal sequence_finished
signal finished_opening

var _steps: Array[TutorialStep] = []
var _index: int = -1
var _current_step: TutorialStep = null
var _completion_callable: Callable = Callable()
var _pressed_actions: Dictionary = {}
var _detection_enabled: bool = false

func _ready() -> void:
	finished_opening.connect(_enable_detection)

func _process(_delta: float) -> void:
	if not _detection_enabled:
		return
	if _current_step == null or _current_step.completion_mode != TutorialStep.CompletionMode.BUTTON_PRESS:
		return
	if _current_step.buttons.is_empty():
		return
	
	if _current_step.require_all_buttons:
		for action in _current_step.buttons:
			if Input.is_action_just_pressed(action):
				_pressed_actions[action] = true
		if _pressed_actions.size() >= _current_step.buttons.size():
			complete_current_step()
	else:
		for action in _current_step.buttons:
			if Input.is_action_just_pressed(action):
				complete_current_step()
				return

func start(steps: Array[TutorialStep]) -> void:
	_disconnect_current()
	_steps = steps
	_index = -1
	_advance()

func _advance() -> void:
	_disconnect_current()
	_detection_enabled = false
	_index += 1
	
	# if array has unfilled slots, do not show empty tutorial UI
	while _index < _steps.size() and _steps[_index] == null:
		_index += 1
	
	if _index >= _steps.size():
		_current_step = null
		sequence_finished.emit()
		return
	
	_current_step = _steps[_index]
	_pressed_actions.clear()
	
	if _current_step.completion_mode == TutorialStep.CompletionMode.GAME_EVENT:
		var arg_count := _signal_arg_count(_current_step.game_event_name)
	
		if _current_step.weapon_name != "" and arg_count > 0:
			_completion_callable = Callable(self, "_on_step_completed_with_arg")
			if arg_count > 1:
				_completion_callable = _completion_callable.unbind(arg_count - 1)
		else:
			_completion_callable = Callable(self, "_on_step_completed")
			if arg_count > 0:
				_completion_callable = _completion_callable.unbind(arg_count)
	
		EventManager.connect(_current_step.game_event_name, _completion_callable)
	else:
		_completion_callable = Callable()

	step_shown.emit(_current_step)

# manual step completion
func complete_current_step() -> void:
	if _current_step and _detection_enabled:
		_advance()

func _on_step_completed() -> void:
	if _detection_enabled:
		_advance()

# only advances if the event's first argument matches weapon_name
func _on_step_completed_with_arg(arg) -> void:
	if str(arg) == _current_step.weapon_name and _detection_enabled:
		_advance()

# stop listening for previous steps requirement
func _disconnect_current() -> void:
	if _current_step and _current_step.completion_mode == TutorialStep.CompletionMode.GAME_EVENT and EventManager.is_connected(_current_step.game_event_name, _completion_callable):
		EventManager.disconnect(_current_step.game_event_name, _completion_callable)

# events carry different argument counts (e.g. shots_fired(shots), gun_picked_up())
func _signal_arg_count(signal_name: StringName) -> int:
	for sig in EventManager.get_signal_list():
		if sig.name == signal_name:
			return sig.args.size()
	return 0

# disable completion detection lockout for when the popup fully loads
func _enable_detection() -> void:
	_detection_enabled = true
	
	EventManager.tutorial_step_started.emit(_current_step.title)
