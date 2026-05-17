extends Area3D

@export var team_component: Node
@export var health_component: Node

@export var damage_multiplier: float = 1.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	

func _on_area_entered(hitbox: Area3D) -> void:
	if team_component == null or hitbox.team_component == null:
		take_hit(hitbox)
	elif team_component.team != hitbox.team_component.team:
		take_hit(hitbox)
	else:
		return


## Handles taking damage by making callbacks to health component. Alerts the hitbox that a collision has occured.
func take_hit(hitbox: Area3D) -> void:
	print("Hit Taken")
	hitbox.call("register_hit", self)
	if hitbox.damage_or_heal_instance != null and health_component != null:
		# apply damage multiplier to damage
		hitbox.damage_or_heal_instance.amount *= damage_multiplier
		health_component.take_damage_or_heal(hitbox.damage_or_heal_instance)
	
