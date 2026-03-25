extends TextureProgressBar

@export var insanity_bar: TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	insanity_bar.value = 0
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_health_initialiased(init_current_health, init_max_health):
	value = init_current_health
	max_value = init_max_health

func _on_player_health_changed(old_health, new_health, damage_or_heal_instance):
	value = new_health

func _on_player_insanity_gained(amount, buffer):
	insanity_bar.value += amount
	value = insanity_bar.value + buffer

## When Interest Rank changes, the appearance of the Interest Bar will change
## TODO: Once the actual UI is designed, set up variables that the bar will
## change to. Tint_progress is a temp solution.
func _on_player_interest_rank_changed(new_rank):
	match new_rank:
		Enums.InterestRank.LOW:
			tint_progress = Color(0.078, 0.392, 0.697, 1.0)
		Enums.InterestRank.MEDLOW:
			tint_progress = Color(0.384, 0.349, 0.794, 1.0)
		Enums.InterestRank.MEDHIGH:
			tint_progress = Color(0.555, 0.306, 0.634, 1.0)
		Enums.InterestRank.HIGH:
			tint_progress = Color(0.796, 0.0, 0.631, 1.0)
