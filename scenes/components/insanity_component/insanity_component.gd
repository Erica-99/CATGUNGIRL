extends Node

## Check health to keep track of Insanity Rank and Level.
## Rank updates with health changes, Level with deaths

signal rank_changed(old_rank: Enums.InsanityRank, new_rank: Enums.InsanityRank)
signal ilevel_changed(new_ilevel: int)

var _health_check: float
var _rank: Enums.InsanityRank
var _ilevel: int

# Called when the node enters the scene tree for the first time.
func _ready():
	## Default rank and level
	_rank = Enums.InsanityRank.MEDIUM
	_ilevel = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

## When the player's health changes, check if it would change the rank,
## and emit a signal if it does.
func _on_health_component_health_changed(old_health, new_health, damage_or_heal_instance):
	_health_check = new_health
	var old_rank = _rank
	if (0 <= _health_check and _health_check < 33):
		_rank = Enums.InsanityRank.LOW
	elif (33 <= _health_check and _health_check < 66):
		_rank = Enums.InsanityRank.MEDIUM
	else:
		_rank = Enums.InsanityRank.HIGH
	
	if _rank != old_rank:
		rank_changed.emit(old_rank, _rank)
		print("Rank Changed: " + str(_rank))

## When killed, increase Insanity Level and emit a signal for it
func _on_health_component_killed(killing_blow):
	_ilevel += 1
	ilevel_changed.emit(_ilevel)
	print("Died - Insanity Level: " + str(_ilevel))
