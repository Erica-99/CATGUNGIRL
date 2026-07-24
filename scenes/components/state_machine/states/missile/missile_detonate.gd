extends State
class_name MissileDetonate

@export var explosion_scene: PackedScene

var body: CharacterBody3D

func enter() -> void:
	body = blackboard["actor"]
	body.velocity = Vector3.ZERO
	
	#var explosion = explosion_scene.instantiate()
	#explosion.global_position = body.global_position
	#body.get_parent().add_child(explosion)
	
	body.queue_free()
