extends Node

signal insanity_death()

signal interest_rank_changed(new_rank: Enums.InterestRank)

@export_category("Interest")
## Interest value is equal to Health in Health Component
@export var interest_rank: Enums.InterestRank ## Will be based on health
## Variables for Interest decay ticks
@export var decay_damage_instance: DamageHealInstance
@export var interest_decay_cd: float = 1
@export var health_component: Node

var _do_interest_tick := true
var _interest_decay_timer: float = 0

func _ready():
	EventManager.connect("begin_date_scene_lock", _on_date_scene_lock)
	EventManager.connect("end_date_scene_lock", _on_end_date_scene_lock)

func _process(delta):
	## Decay over time
	if _do_interest_tick:
		_interest_decay_timer += delta
		if _interest_decay_timer > interest_decay_cd:
			_interest_decay_timer = 0
			health_component.take_damage_or_heal(decay_damage_instance)

## The player reacts to being killed differently, the overflow damage
## done by the killing blow is added to Insanity.
## Player death will be handled by Insanity reaching 100
func _on_health_component_killed(killing_blow, health_before_death):
	## If not already at 0hp, set to 0hp. Otherwise kill them fr.
	if health_before_death != 0:
		health_component.set_health_to_min()
	else:
		insanity_death.emit() # Name is a holdover from previous implementation. Will change later. Keeping for now to avoid breaking things.

func _on_health_component_health_changed(old_health, new_health, damage_or_heal_instance):
	var old_rank = interest_rank
	## Ranks in quarters of health
	if (0 <= new_health and new_health < 25):
		interest_rank = Enums.InterestRank.LOW
	elif (25 <= new_health and new_health < 50):
		interest_rank = Enums.InterestRank.MEDLOW
	elif (50 <= new_health and new_health < 75):
		interest_rank = Enums.InterestRank.MEDHIGH
	else:
		interest_rank = Enums.InterestRank.HIGH
	
	## If rank has changed emit signal
	if old_rank != interest_rank:
		interest_rank_changed.emit(interest_rank)


func _on_player_player_dead() -> void:
	insanity = 0

func _on_date_scene_lock() -> void:
	_do_interest_tick = false

func _on_end_date_scene_lock() -> void:
	_do_interest_tick = true
