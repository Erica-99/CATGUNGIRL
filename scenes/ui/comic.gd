extends CanvasLayer

@export var comics: Dictionary[String,Array]

var selected_comic: Array
var selected_comic_name: String
var current_page_index: int

var current_actual_page_object: Control = null

var debug_triggered = false

func _ready() -> void:
	EventManager.play_comic.connect(_play_comic)
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_load_comic_start") and not debug_triggered:
		debug_triggered = true
		_play_comic("start_comic")

func _play_comic(comic_name: String) -> void:
	visible = true
	if not comic_name in comics.keys():
		return
	else:
		selected_comic = comics[comic_name]
		selected_comic_name = comic_name
		current_page_index = 0
		_open_page()
		_fade_in()

func _open_page() -> void:
	if current_actual_page_object != null and is_instance_valid(current_actual_page_object):
		current_actual_page_object.queue_free()
	current_actual_page_object = selected_comic[current_page_index].instantiate()
	add_child(current_actual_page_object)
	current_actual_page_object.connect("comic_finished", _current_comic_finished)
	

func _current_comic_finished() -> void:
	current_actual_page_object.disconnect("comic_finished", _current_comic_finished)
	current_page_index += 1
	if current_page_index >= selected_comic.size():
		if selected_comic_name == "start_comic":
			EventManager.instant_void.emit(false)
		else:
			EventManager.instant_void.emit(true)
		_fade_out()
	else:
		_fade_between()

func _fade_in() -> void:
	$AnimationPlayer.play("fade_in")

func _fade_out() -> void:
	$AnimationPlayer.play("fade_out")

func _fade_between() -> void:
	$AnimationPlayer.play("fade_between")

func _move_on() -> void:
	if current_actual_page_object != null and is_instance_valid(current_actual_page_object):
		current_actual_page_object.queue_free()
	EventManager.total_comic_finished.emit(selected_comic_name)
	visible = false
