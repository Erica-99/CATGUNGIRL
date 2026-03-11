class_name PlayerStats
extends Resource

@export var health: float
@export var base_damage: float

# Also store upgrades in here. They will probably need to also be another resource.

func _init(p_health: float, p_base_damage: float) -> void:
	health = p_health
	base_damage = p_base_damage
