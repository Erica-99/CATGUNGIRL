extends Node

var shields
var health

@export var health_bar : ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shields = $ShieldCollision
	shields.body_entered.connect(_on_body_entered)
	health_bar.init_health(health)
	disable_shields()

func _on_body_entered(body):
	if body.collision_layer and (1 << 5) != 0:
		body.queue_free()

func _on_health_component_health_initialised(init_current_health: float, init_max_health: float) -> void:
	health = init_max_health
	print(health)

func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	health = new_health
	print(health)
	health_bar.health = health
	enable_shields()

func disable_shields():
	shields.monitoring = false

func enable_shields():
	shields.monitoring = true
