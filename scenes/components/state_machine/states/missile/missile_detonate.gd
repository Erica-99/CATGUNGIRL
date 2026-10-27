extends State
class_name MissileDetonate



@export var explosion_scene: PackedScene

var body: CharacterBody3D

func enter() -> void:
	body = blackboard["actor"]
	body.velocity = Vector3.ZERO
	
	var explosion = explosion_scene.instantiate()
	explosion.get_node("HitboxComponent").ignored_actor = body.get("fired_by")
	get_tree().root.add_child(explosion)
	explosion.global_position = body.global_position
	
	body.queue_free()
