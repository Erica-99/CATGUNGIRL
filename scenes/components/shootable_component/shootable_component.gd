extends Node

# references
@onready var hurtbox_component: Area3D = $HurtboxComponent
@onready var hurtbox_collision: CollisionShape3D = $HurtboxComponent/HurtboxCollision
@onready var team_component: Node = $TeamComponent
@onready var health_component: Node = $HealthComponent

@export var animation_player: AnimationPlayer

# variables
var is_collision_generated: bool = false
var parent_mesh: MeshInstance3D
var ancestor: StaticBody3D

# constants
const internal_collision_scale: float = 0.6

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	
	parent_mesh = get_parent()
	ancestor = parent_mesh.get_parent()

func _generate_collision():
	# generate physical collision instance
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = parent_mesh.mesh.create_trimesh_shape()
	# set to a smaller scale - means the player may clip slightly but bullets will register
	collision_shape.scale = Vector3(internal_collision_scale,internal_collision_scale, internal_collision_scale)
	
	ancestor.add_child(collision_shape)
	
	# assign hurtbox collision shape (this is the external layer of the collision box)
	hurtbox_collision.shape = parent_mesh.mesh.create_trimesh_shape()

# check whether collision loaded - if not load collision
# this has been put into process because ready wasnt ready (false advertising fr)
func _process(delta: float) -> void:
	if not is_collision_generated:
		_generate_collision()
		is_collision_generated = true

# play animation on killed
func _on_health_component_killed(killing_blow: DamageHealInstance, health_before_death: Variant) -> void:
	if animation_player != null:
		if animation_player.has_animation("on_destroy"):
			animation_player.play("on_destroy")
		else:
			_on_animation_finished("")
	else:
		_on_animation_finished("")
	
# play animation on hurt
func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	if animation_player != null:
		if animation_player.has_animation("on_damaged"):
			animation_player.play("on_damaged")

# if dead, delete self
func _on_animation_finished(animation_name: String):
	if animation_name == "" || animation_name == "on_destroy":
		ancestor.queue_free()
