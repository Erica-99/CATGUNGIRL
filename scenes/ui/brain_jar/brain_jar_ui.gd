extends ProgressBar

var health = 0 : set = set_health

func set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health

func init_health(_health):
	health = _health
	max_value = _health
	value = health
