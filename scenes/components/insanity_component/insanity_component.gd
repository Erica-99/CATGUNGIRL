extends Node

## Check health to keep track of Interest and Insanity

## Interest: "Shield Health" and Style Ranking, doing damage,
## etc. will raise Interest, taking damage lowers it.
## Interest uses the Health Component as it's basis

## Insanity: "Real Health", starts at 0 and game over at 100.
## When taking damage without having the Interest shield, the Insanity
## value raises. The Insanity value determines the minimum Interest
## "health". This means high Insanity locks you into a high Style, but
## also brings you closer and closer to death.

signal insanity_gained(amount: float, buffer: float)
signal insanity_death()

signal interest_rank_changed(new_rank: Enums.InterestRank)

@export_category("Interest")
## Interest value is equal to Health in Health Component
@export var interest_rank: Enums.InterestRank ## Will be based on health
## Variables for Interest decay ticks
@export var decay_damage_instance: DamageHealInstance
@export var intdecay_timer: float = 0
@export var intdecay_cd: float = 1
@export var min_decayable_health: int = 1
@export var health_component: Node

@export_category("Insanity")
@export var insanity: float
@export var max_insanity: float = 5

func _ready():
	insanity = 0

func _process(delta):
	## Decay over time
	intdecay_timer += delta
	if intdecay_timer > intdecay_cd:
		intdecay_timer = 0
		health_component.take_damage_or_heal(decay_damage_instance)
	
	## When reaching Max Insanity, die
	if insanity >= max_insanity:
		insanity_death.emit()

## The player reacts to being killed differently, the overflow damage
## done by the killing blow is added to Insanity.
## Player death will be handled by Insanity reaching 100
func _on_health_component_killed(killing_blow, health_before_death):
	## If not already at 0hp, set to 0hp. Otherwise kill them fr.
	if health_before_death != 0:
		health_component.set_health_to_min()
	else:
		insanity_death.emit()

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
