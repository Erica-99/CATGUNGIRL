extends Node

## Health will be gained through actions like shooting enemies,
## headshots, etc. And lost from getting hit.

signal health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance)
signal killed(killing_blow: DamageHealInstance)

## Health variables
var _current_health: float
var _starting_health: float
var _min_health: float
var _max_health: float

@export_category("Health Values")
@export var current_health: float:
	get:
		return _current_health
	set(value):
		set_health(value)

@export var starting_health: float:
	get:
		return _starting_health
	set(value):
		set_starting_health(value)

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

@export_category("Damage States")
@export var damageable: bool = true
@export var healable: bool = true
@export var killable: bool = true

func _ready() -> void:
	initialize_health()

## Initializes health value to starting health. Will not trigger any heal/damage side effects.
func initialize_health() -> void:
	_current_health = _starting_health

## Set the starting health to the specified value
func set_starting_health(value: float) -> void:
	_starting_health = value

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

## _process(delta) allows for updates independent of actual framerate.
## It will check if the player hasn't "healed", and start decaying health
func _process(delta):
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
