extends Node

## For this game, health works for the "Insanity" mechanic.
## The plan is that Insanity will be gained through actions like shooting enemies,
## headshots, etc. Lost from getting hit. 
## It should also start to decay if you haven't gained any after a set time.

signal health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance)
signal killed(killing_blow: DamageHealInstance)

## Health variables
var _current_health: float
var _min_health: float
var _max_health: float

## Decay variables
var _decay_cd: float
var _decay_tick: float
var _decay_timer: float
var _decay_tick_timer: float
var _decay_damage: DamageHealInstance

@export_category("Health Values")
@export var current_health: float:
	get:
		return _current_health
	set(value):
		set_health(value)

@export var min_health: float:
	get:
		return _min_health
	set(value):
		set_min_health(value)

@export var max_health: float:
	get:
		return _max_health
	set(value):
		set_max_health(value)

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

@export_category("Damage States")
@export var damageable: bool = true
@export var healable: bool = true
@export var killable: bool = true

func _ready() -> void:
	initialize_health()
	_decay_timer = 0
	_decay_tick_timer = 0
	
	## Basic setup for decay damage
	_decay_damage = DamageHealInstance.new()
	_decay_damage.amount = 1
	_decay_damage.is_heal = false
	_decay_damage.type = Enums.DamageType.DECAY
	_decay_damage.knockback = 0
	_decay_damage.source = ^"."

## Initializes health value to starting health. Will not trigger any heal/damage side effects.
func initialize_health() -> void:
	_current_health = ((max_health + min_health)/2)

## Sets min health to the specified value.
func set_min_health(value: float) -> void:
	_min_health = value
	if current_health < min_health:
		set_health(value + 1)

## Sets max health to the specified value. Reduces current health if max health is reduced below it.
func set_max_health(value: float) -> void:
	_max_health = value
	if current_health > max_health:
		set_health(value)

## Set the cooldown until health starts to decay. In seconds.
func set_decay_cd(value: float) -> void:
	_decay_cd = value
	
## Set how quickly health ticks down in decay.
func set_decay_tick(value: float) -> void:
	_decay_tick = value

## Sets current health to the specified value.
func set_health(value: float) -> void:
	_current_health = clampf(value, 0, max_health)

## Take the specified damage or heal instance
func take_damage_or_heal(damage_or_heal_instance: DamageHealInstance) -> void:
	if damageable and not damage_or_heal_instance.is_heal:
		var prev_health = current_health
		current_health -= damage_or_heal_instance.amount
		health_changed.emit(prev_health, current_health, damage_or_heal_instance)
		
		if killable and current_health <= min_health:
			killed.emit(damage_or_heal_instance)
		
	elif healable and damage_or_heal_instance.is_heal:
		var prev_health = current_health
		current_health += damage_or_heal_instance.amount
		health_changed.emit(prev_health, current_health, damage_or_heal_instance)
		## When healed reset decay timer
		_decay_timer = 0
		_decay_tick_timer = 0

## _process(delta) allows for updates independent of actual framerate.
## It will check if the player hasn't "healed", and start decaying health
func _process(delta):
	_decay_timer += delta
	if _decay_timer > _decay_cd:
		_decay_tick_timer += delta
		if _decay_tick_timer > _decay_tick:
			_decay_tick_timer = 0
			take_damage_or_heal(_decay_damage)
			print("Decay. Health: " + str(_current_health))
	
	## Basic debug to test healing and resetting decay
	if Input.is_action_just_pressed("debug_heal"):
		var debug_heal = DamageHealInstance.new()
		debug_heal.amount = 10
		debug_heal.is_heal = true
		debug_heal.type = Enums.DamageType.NORMAL
		debug_heal.knockback = 0
		debug_heal.source = ^"."
		
		take_damage_or_heal(debug_heal)
		print("Healed. Health: " + str(_current_health))


func _on_insanity_component_ilevel_changed(new_ilevel):
	match(new_ilevel):
		0:
			min_health = 0
			set_health((max_health + min_health)/2)
		1:
			min_health = 33
			set_health((max_health + min_health)/2)
		_:
			min_health = 66
			set_health((max_health + min_health)/2)
