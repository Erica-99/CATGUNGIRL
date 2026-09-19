extends Node3D

@onready var anim = $AnimationPlayer


func _on_area_3d_body_entered(body: Node3D) -> void:
	anim.play("Appear")
	pass # Replace with function body.


func _on_area_3d_body_exited(body: Node3D) -> void:
	anim.play("Dissappear")
	pass # Replace with function body.
