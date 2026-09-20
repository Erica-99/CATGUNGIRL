extends StaticBody3D


func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	EventManager.dummy_hit.emit()
