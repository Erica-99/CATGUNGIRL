extends TextureProgressBar

@export var insanity_bar: TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.player_health_initialised.connect(_on_player_health_initialiased)
	EventManager.player_health_changed.connect(_on_player_health_changed)
	insanity_bar.value = Globals.health_percent_lost_per_insanity * Globals.global_insanity_level
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_health_initialiased(init_current_health, init_max_health):
	value = init_current_health
	max_value = init_max_health

func _on_player_health_changed(old_health, new_health, damage_or_heal_instance):
	value = new_health
