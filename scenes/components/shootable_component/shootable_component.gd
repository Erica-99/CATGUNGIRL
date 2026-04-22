extends Node
# references
@onready var hurtbox_component: Area3D = $HurtboxComponent
@onready var hurtbox_collision: CollisionShape3D = $HurtboxComponent/HurtboxCollision
@onready var team_component: Node = $TeamComponent
@onready var health_component: Node = $HealthComponent

# variables
var parent_reference: StaticBody3D
var parent_animation_player: AnimationPlayer
var is_collision_generated: bool = false

# constants
const internal_collision_scale: float = 0.7

func _ready() -> void:
	parent_reference = get_parent()
		
	# set animation player and link signals if animations exist
	var parent_animation_children = parent_reference.find_children("*", "AnimationPlayer", false)
	if parent_animation_children.size() > 0:
		parent_animation_player = parent_animation_children[0]
		parent_animation_player.animation_finished.connect(_on_animation_finished)

func _generate_collision():
	parent_reference = get_parent()
	
	# this code sucks so bad and entirely breaks inheritance
	# fix it when i have time
	var parent_collision_children = parent_reference.find_children("*", "MeshInstance3D", false)
	if parent_collision_children.size() > 0:
		# get MeshInstance3D from parent
		var mesh = parent_collision_children[0]
		
		# generate physical collision instance
		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = mesh.mesh.create_trimesh_shape()
		# set to a smaller scale - means the player may clip slightly but bullets will register
		collision_shape.scale = Vector3(internal_collision_scale,internal_collision_scale, internal_collision_scale)
		
		parent_reference.add_child(collision_shape)
		
		# assign hurtbox collision shape (this is the external layer of the collision box)
		hurtbox_collision.shape = parent_collision_children[0].mesh.create_trimesh_shape()


# check whether collision loaded - if not load collision
# this has been put into process because ready wasnt ready (false advertising fr)
func _process(delta: float) -> void:
	if not is_collision_generated:
		_generate_collision()
		is_collision_generated = true

# play animation on killed
func _on_health_component_killed(killing_blow: DamageHealInstance, health_before_death: Variant) -> void:
	if parent_animation_player != null:
		if parent_animation_player.has_animation("on_destroy"):
			parent_animation_player.play("on_destroy")
		else:
			_on_animation_finished("")
	else:
		_on_animation_finished("")
	
# play animation on hurt
func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	if parent_animation_player != null:
		if parent_animation_player.has_animation("on_damaged"):
			parent_animation_player.play("on_damaged")

# if dead, delete self
func _on_animation_finished(animation_name: String):
	if animation_name == "" || animation_name == "on_destroy":
		get_parent().queue_free()
