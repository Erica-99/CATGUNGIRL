extends VBoxContainer

@export var separation_mappings: Dictionary[String, int]

func set_settings_for_gun(gun: String) -> void:
	if gun in separation_mappings.keys():
		add_theme_constant_override("separation", separation_mappings[gun])
	else:
		add_theme_constant_override("separation", separation_mappings.values()[0])
