extends Node
@onready var hurtbox_component: Area3D = $HurtboxComponent
@onready var hurtbox_collision: CollisionShape3D = $HurtboxComponent/HurtboxCollision
@onready var internal_collision: CollisionShape3D = $InternalArea/InternalCollision

@onready var team_component: Node = $TeamComponent
@onready var health_component: Node = $HealthComponent

var parent_reference: StaticBody3D
var parent_animation_player: AnimationPlayer

const internal_collision_scale: float = 0.9

func _ready() -> void:
	parent_reference = get_parent()
	# res://art/3D_Env/3D_Assets/BarrelGoo.tscn::ConvexPolygonShape3D_x15ns
	
	var parent_collision_children = parent_reference.find_children("*", "MeshInstance3D", false)
	if parent_collision_children.size() > 0:
		parent_collision_children[0].create_trimesh_collision()
		#var collision_shape = CollisionShape3D.new()
		#collision_shape.shape = mesh
		#print(mesh)
		#parent_collision_children[0].add_child(collision_shape)
		
		
		hurtbox_collision.shape = parent_collision_children[0].mesh.create_trimesh_shape()
		#internal_collision.shape = mesh
		#internal_collision.scale = Vector3(internal_collision_scale,internal_collision_scale, internal_collision_scale)
		#print(internal_collision.scale)
	
	#var parent_collision_children = parent_reference.find_children("*", "CollisionShape3D", false)
	#if parent_collision_children.size() > 0:
	#	collision_shape_3d.shape = parent_collision_children[0].shape
		
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
