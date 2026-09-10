extends CanvasLayer

signal loading_screen_ready

@export var animation_player: AnimationPlayer
 
func _ready() -> void:
	await animation_player.animation_finished
	loading_screen_ready.emit()

# Used to track the percentage of the load.
# TODO: if we want to add a loading bar use this
func _on_progress_changed(new_value: float) -> void:
	pass

# Happens when the scene has been loaded and switch to.
# Reverses loading screen animation to fade out
func _on_load_finished() -> void:
	animation_player.play_backwards()
	await animation_player.animation_finished
	queue_free()
