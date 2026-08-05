@tool
class_name ChromaticAberrationCompositorEffect
extends "res://art/Shaders/CompositorEffects/compositor_effect_base.gd"

## displacements are in pixels at internal render resolution

@export var r_displacement := Vector2(3.0, 0.0)
@export var g_displacement := Vector2(0.0, 0.0)
@export var b_displacement := Vector2(-3.0, 0.0)


func _get_shader_path() -> String:
	return "res://art/Shaders/CompositorEffects/ChromaticAberration/chromatic_aberration.glsl"


func _get_push_constant(size: Vector2i) -> PackedFloat32Array:
	return PackedFloat32Array([
		size.x, size.y,
		r_displacement.x, r_displacement.y,
		g_displacement.x, g_displacement.y,
		b_displacement.x, b_displacement.y,
	])


func _needs_color_copy() -> bool:
	return true
