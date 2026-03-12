extends State
class_name PlayerIdle

var actor: CharacterBody3D

func enter() -> void:
	await get_tree().create_timer(5).timeout
	transitioned.emit(self, "playermove")
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
