extends Node

signal health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance)
signal killed(killing_blow: DamageHealInstance)

var _current_health: float
var _max_health: float

@export var current_health: float:
	get:
		return _current_health
	set(value):
		set_health(value)

@export var max_health: float:
	get:
		return _max_health
	set(value):
		set_max_health(value)

@export var damageable: bool = true
@export var healable: bool = true
@export var killable: bool = true


func _ready() -> void:
	initialize_health()


## Initializes health value to max health. Will not trigger any heal/damage side effects.
func initialize_health() -> void:
	_current_health = _max_health


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
		
		if killable and current_health <= 0:
			killed.emit(damage_or_heal_instance)
		
	elif healable and damage_or_heal_instance.is_heal:
		var prev_health = current_health
		current_health += damage_or_heal_instance.amount
		health_changed.emit(prev_health, current_health, damage_or_heal_instance)
		
