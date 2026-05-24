extends ColorRect
class_name VignetteController

@export var insanity_low: VignettePreset
@export var insanity_high: VignettePreset


func apply_preset(p: VignettePreset) -> void:
	material.set("shader_parameter/radius", p.radius)
	material.set("shader_parameter/softness", p.softness)
	material.set("shader_parameter/intensity", p.intensity)
	material.set("shader_parameter/contrast", p.contrast)
	material.set("shader_parameter/vignette_color", p.color)
