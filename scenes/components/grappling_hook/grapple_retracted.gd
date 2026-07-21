extends State
class_name GrappleRetracted

var primed = false

func enter() -> void:
	pass
	
func exit() -> void:
	pass

func update(_delta: float) -> void:
	if primed:
		primed = false
		transitioned.emit(self, "GrappleShooting")

func physics_update(_delta: float) -> void:
	pass
