extends Node

const MISSILE = preload("uid://bt57arw8qv0ya")

func launch_missile() -> void:
	var new_missile = MISSILE.instantiate()
	
	add_child(new_missile)
