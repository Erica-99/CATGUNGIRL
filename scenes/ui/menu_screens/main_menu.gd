extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(Globals.LEVEL_PATHS["Stage1"])
	pass # Replace with function body.
