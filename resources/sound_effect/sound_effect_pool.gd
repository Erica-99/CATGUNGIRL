extends CallableSFX
class_name SoundEffectPool

@export var sfx_pool: Array[SoundEffect]

func get_sfx() -> SoundEffect:
	# Verify pool isn't empty
	if sfx_pool.is_empty():
		return null
	
	var random_sfx: SoundEffect = select_sfx_from_pool()
	return random_sfx.get_sfx()

# Get random sfx based off of sfx weighting
func select_sfx_from_pool():
	
	# Calculate total pool weight
	var total_weight: float = 0
	for sfx in sfx_pool:
		total_weight += sfx.pool_weighting
	
	if total_weight <= 0.0:
		push_error("SoundEffectPool has no weight")
		return null
	
	# Get point (value) between 0 and total_weight
	var pick: float = randf() * total_weight
	
	var cumulative: float = 0.0

	# Steps through each slice of the pool and determines which sfx slice the pick number is associated with
	for sfx in sfx_pool:
		cumulative += sfx.pool_weighting
		if pick <= cumulative:
			return sfx
