extends CanvasLayer

@export var anims: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.brainjar_killed.connect(_run_end_sequence)

func _run_end_sequence() -> void:
	EventManager.begin_date_scene_lock.emit() # hack to cut off player input
	visible = true
	anims.play("game_end")

func _restart_game() -> void:
	Globals._reset_game()
	SceneLoader._load_scene(Globals.LEVEL_PATHS["main_menu"])
