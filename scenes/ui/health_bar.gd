extends TextureProgressBar

@export var insanity_bar: TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	EventManager.player_health_initialised.connect(_on_player_health_initialiased)
	EventManager.player_health_changed.connect(_on_player_health_changed)
	EventManager.insanity_changed.connect(_on_insanity_changed)
	EventManager.player_interest_rank_changed.connect(_on_player_interest_rank_changed)
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

func _on_insanity_changed(prev_rank: int, new_rank: int):
	insanity_bar.value = Globals.health_percent_lost_per_insanity * new_rank

## When Interest Rank changes, the appearance of the Interest Bar will change
## TODO: Once the actual UI is designed, set up variables that the bar will
## change to. Tint_progress is a temp solution.
func _on_player_interest_rank_changed(new_rank):
	match new_rank:
		Enums.InterestRank.LOW:
			tint_progress = Color(0.698, 0.02, 1.0, 1.0)
		Enums.InterestRank.MEDLOW:
			tint_progress = Color(1.0, 0.529, 1.0, 1.0)
		Enums.InterestRank.MEDHIGH:
			tint_progress = Color(1.0, 0.529, 1.0, 1.0)
		Enums.InterestRank.HIGH:
			tint_progress = Color(1.0, 0.529, 1.0, 1.0)
