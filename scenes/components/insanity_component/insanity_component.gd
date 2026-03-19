extends Node

## Check health to keep track of Insanity Rank and Level.
## Rank updates with health changes, Level with deaths

signal rank_changed(old_rank: Enums.InsanityRank, new_rank: Enums.InsanityRank)
signal ilevel_changed(new_ilevel: int)

## Checking rank
var _health_check: float
var _rank: Enums.InsanityRank
## Insanity Level
var _ilevel: int
## Decay variables
var _decay_cd: float
var _decay_tick: float
var _decay_timer: float
var _decay_tick_timer: float
var _decay_damage: DamageHealInstance
var _decay_target: Node

@export_category("Decay Values")
@export var decay_cd: float:
	get:
		return _decay_cd
	set(value):
		set_decay_cd(value)

@export var decay_tick: float:
	get:
		return _decay_tick
	set(value):
		set_decay_tick(value)

# Called when the node enters the scene tree for the first time.
func _ready():
	## Default rank and level
	_rank = Enums.InsanityRank.MEDIUM
	_ilevel = 0
	
	## Setup for decay damage
	_decay_damage = DamageHealInstance.new()
	_decay_damage.amount = 1
	_decay_damage.is_heal = false
	_decay_damage.type = Enums.DamageType.DECAY
	_decay_damage.knockback = 0
	_decay_damage.source = ^"."
	## Set target for decay, Player's Health Component
	_decay_target = $"../HealthComponent"

## Set the cooldown until health starts to decay. In seconds.
func set_decay_cd(value: float) -> void:
	_decay_cd = value
	
## Set how quickly health ticks down in decay.
func set_decay_tick(value: float) -> void:
	_decay_tick = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_decay_timer += delta
	if _decay_timer > _decay_cd:
		_decay_tick_timer += delta
		if _decay_tick_timer > _decay_tick:
			_decay_tick_timer = 0
			_decay_target.take_damage_or_heal(_decay_damage)
			print("Decay. Health: " + str(_decay_target.current_health))
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
	
	## When healed reset decay timer
	if (damage_or_heal_instance.is_heal):
		_decay_timer = 0
		_decay_tick_timer = 0
	
	if _rank != old_rank:
		rank_changed.emit(old_rank, _rank)
		print("Rank Changed: " + str(_rank))

## When killed, increase Insanity Level and emit a signal for it
func _on_health_component_killed(killing_blow):
	_ilevel += 1
	ilevel_changed.emit(_ilevel)
	print("Died - Insanity Level: " + str(_ilevel))
