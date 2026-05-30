extends ColorRect
class_name ChromaticController

func apply_aberration(r: Vector2, g: Vector2, b: Vector2) -> void:
	material.set("shader_parameter/r_displacement", r)
	material.set("shader_parameter/g_displacement", g)
	material.set("shader_parameter/b_displacement", b)
