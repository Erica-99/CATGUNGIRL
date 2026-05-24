extends Node

var shields
var health

@export var health_bar : ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.shield_enabled_status.connect(_disable_shields)
	
	shields = $Shields/CollisionShape3D
	health_bar.init_health(health)
	_disable_shields()

func _on_health_component_health_initialised(init_current_health: float, init_max_health: float) -> void:
	health = init_max_health
	print(health)

func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	if (old_health - new_health) != (health_bar.max_value / 5):
		new_health = health - (health_bar.max_value / 5)
	health = new_health
	print(health)
	health_bar.health = health
	_enable_shields()

func _disable_shields(signal_val = false):
	if !signal_val:
		shields.disabled = true

func _enable_shields():
	shields.disabled = false
	EventManager.shield_enabled_status.emit(true)
