extends Node
@onready var hurtbox_component: Area3D = $HurtboxComponent
@onready var collision_shape_3d: CollisionShape3D = $HurtboxComponent/CollisionShape3D
@onready var team_component: Node = $TeamComponent
@onready var health_component: Node = $HealthComponent

var parent_reference: StaticBody3D
var parent_animation_player: AnimationPlayer

func _ready() -> void:
	parent_reference = get_parent()
	var parent_collision_children = parent_reference.find_children("*", "CollisionShape3D", false)
	if parent_collision_children.size() > 0:
		collision_shape_3d.shape = parent_collision_children[0].shape
		
	var parent_animation_children = parent_reference.find_children("*", "AnimationPlayer", false)
	if parent_animation_children.size() > 0:
		parent_animation_player = parent_animation_children[0]
		parent_animation_player.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	pass

func _on_health_component_killed(killing_blow: DamageHealInstance, health_before_death: Variant) -> void:
	parent_animation_player.play("on_destroy")
	
func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	parent_animation_player.play("on_damaged")

func _on_animation_finished(animation_name: String):
	if animation_name == "on_destroy":
		get_parent().queue_free()
