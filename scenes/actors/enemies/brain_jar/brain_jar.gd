extends Node

var shields
var health

@export var health_bar : ProgressBar
@export var health_component: HealthComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.shield_enabled_status.connect(_disable_shields)
	
	shields = $Shields/CollisionShape3D
	health_bar.init_health(health)
	_disable_shields()

func _on_health_component_health_initialised(init_current_health: float, init_max_health: float) -> void:
	health = init_max_health

func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:	
	if ((old_health - new_health) > (health_bar.max_value / 5)) or ((old_health - new_health) < (health_bar.max_value / 5)):
		new_health = health - (health_bar.max_value / 5)
	
	health = new_health
	health_bar.health = health
	if health > 0:
		_enable_shields()
		EventManager.spawn_enemy.emit(0.1, get_path_to($"../EnemyManager/EnemySpawner"))
		EventManager.spawn_enemy.emit(0.1, get_path_to($"../EnemyManager/EnemySpawner2"))
	else:
		# Play out death sequence (e.g. animations, cutscene)
		queue_free()

func _disable_shields(signal_val = false):
	if !signal_val:
		shields.disabled = true
		health_component.damageable = true

func _enable_shields():
	shields.disabled = false
	health_component.damageable = false
	EventManager.shield_enabled_status.emit(true)
