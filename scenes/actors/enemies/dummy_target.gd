extends CharacterBody3D

## target dummy for test scene, will log damage taken and flashes on hit

@onready var health_component = $HealthComponent
@onready var sprite = $AnimatedSprite3D


func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	health_component.killed.connect(_on_killed)


func _on_health_changed(old_health: float, new_health: float, _instance: DamageHealInstance) -> void:
	print("Dummy hit. Health: %.1f -> %.1f" % [old_health, new_health])
	# red flash feedback
	if sprite != null:
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE


func _on_killed(_instance: DamageHealInstance, _health_before_death: float) -> void:
	print("Dummy destroyed!")
	# respawn after short delay 
	if sprite != null:
		sprite.modulate = Color(0.3, 0.3, 0.3)
	await get_tree().create_timer(2.0).timeout
	health_component.current_health = health_component.max_health
	if sprite != null:
		sprite.modulate = Color.WHITE
	print("Dummy respawned.")
