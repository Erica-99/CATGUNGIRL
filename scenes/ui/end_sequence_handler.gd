extends Node

var registered_final_gun: String

var active = false

const COMIC_LOOKUP: Dictionary = {
	"Pistol": "end_pistol",
	"Shotgun": "end_shotgun",
	"Sniper": "end_sniper"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventManager.final_gun_reported.connect(_register_final_gun)
	EventManager.total_comic_finished.connect(_on_total_comic_finished)

func _register_final_gun(gun_name: String) -> void:
	registered_final_gun = gun_name
	
	EventManager.slow_void.emit(true)
	active = true
	AudioManager.cut_music()
	get_tree().paused = true


func _on_void_slow_void_finished(now_visible: bool) -> void:
	if active:
		if now_visible:
			var comic_to_play = COMIC_LOOKUP[registered_final_gun]
			EventManager.play_comic.emit(comic_to_play)
			AudioManager.play_music("spooky")


func _on_total_comic_finished(comic_name: String) -> void:
	if active:
		EventManager.do_credits.emit()
