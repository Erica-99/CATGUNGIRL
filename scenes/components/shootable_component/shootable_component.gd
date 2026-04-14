extends Node
@onready var hurtbox_component: Area3D = $HurtboxComponent
@onready var collision_shape_3d: CollisionShape3D = $HurtboxComponent/CollisionShape3D
@onready var team_component: Node = $TeamComponent
@onready var health_component: Node = $HealthComponent

@export var shoot_behaviour: Behaviour = Behaviour.DESTROY

enum Behaviour {
	DESTROY,
	INTERACTION,
}

var parent_reference: StaticBody3D

func _ready() -> void:
	parent_reference = get_parent()
	var parent_collision_children = parent_reference.find_children("*", "CollisionShape3D", false)
	if parent_collision_children.size() > 0:
		collision_shape_3d.shape = parent_collision_children[0].shape

func _process(delta: float) -> void:
	pass

func _on_health_component_killed(killing_blow: DamageHealInstance, health_before_death: Variant) -> void:
	print("DEAD")
	get_parent().queue_free()
	
func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	print("DAMAGED")
