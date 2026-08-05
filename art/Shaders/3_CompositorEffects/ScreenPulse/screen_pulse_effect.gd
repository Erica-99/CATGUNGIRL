@tool
class_name ScreenPulseCompositorEffect
extends "res://art/Shaders/3_CompositorEffects/compositor_effect_base.gd"

@export var base_strength := 0.03
@export var pulse_strength := 0.12
@export var pulse_speed := 2.5
@export var focus_radius := 0.4


func _get_shader_path() -> String:
	return "res://art/Shaders/3_CompositorEffects/ScreenPulse/screen_pulse.glsl"


func _get_push_constant(size: Vector2i) -> PackedFloat32Array:
	return PackedFloat32Array([
		size.x, size.y,
		Time.get_ticks_msec() / 1000.0,
		base_strength, pulse_strength, pulse_speed, focus_radius,
	])


func _needs_color_copy() -> bool:
	return true
