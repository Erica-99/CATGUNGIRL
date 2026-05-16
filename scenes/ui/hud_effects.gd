extends CanvasLayer

@export var vignette: VignetteController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_hud()
	EventManager.end_date_scene_lock.connect(_update_hud)
	EventManager.insanity_changed.connect(_update_hud)

func _update_hud(prev_rank = null, new_rank = null) -> void:
	match Globals.global_insanity_level:
		0:
			pass
		1:
			vignette.apply_preset(vignette.insanity_low)
		2:
			vignette.apply_preset(vignette.insanity_low)
			AudioManager.play_sfx("heartbeat")
		3:
			vignette.apply_preset(vignette.insanity_low)
		4:
			vignette.apply_preset(vignette.insanity_low)
		5:
			vignette.apply_preset(vignette.insanity_high)
		_:
			print("invalid insanity level")
