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
@export var interest_buffer: float = 10
## Variables for Interest decay ticks
@export var intdecay_damage: DamageHealInstance
@export var intdecay_timer: float = 0
@export var intdecay_cd: float = 1
@export var int_target: Node

@export_category("Insanity")
@export var insanity: float
@export var min_insanity_damage: float
@export var max_insanity: float = 100

func _ready():
	insanity = 0
	## Setting up interest decay
	## TODO: change this to be more easily editable
	intdecay_damage = DamageHealInstance.new()
	intdecay_damage.amount = 1
	intdecay_damage.is_heal = false
	intdecay_damage.knockback = 0
	intdecay_damage.type = Enums.DamageType.DECAY
	intdecay_damage.source = ^"."
	int_target = $"../HealthComponent"
	

func _process(delta):
	## Decay over time
	intdecay_timer += delta
	if intdecay_timer > intdecay_cd:
		intdecay_timer = 0
		int_target.take_damage_or_heal(intdecay_damage)
	
	## When reaching Max Insanity, die
	if insanity >= max_insanity:
		insanity_death.emit()

## The player reacts to being killed differently, the overflow damage
## done by the killing blow is added to Insanity.
## Player death will be handled by Insanity reaching 100
func _on_health_component_killed(killing_blow, health_before_death):
	## Determine how much damage overflow from Interest Damage
	var overflow = killing_blow.amount - health_before_death
	## Set a minumum amount of Insanity damage that can be taken
	if overflow < min_insanity_damage:
		overflow = min_insanity_damage
	
	## After Interest is "killed", add Insanity, making min_health
	## higher, and add a buffer to Interest so you it doesn't break
	## immediately
	insanity += overflow
	insanity_gained.emit(overflow, interest_buffer)

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
