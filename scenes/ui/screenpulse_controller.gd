extends ColorRect
class_name ScreenPulseController

func apply_preset(p: ScreenPulsePreset) -> void:
	material.set("shader_parameter/base_strength", p.base_strength)
	material.set("shader_parameter/pulse_strength", p.pulse_strength)
	material.set("shader_parameter/pulse_speed", p.pulse_speed)
	material.set("shader_parameter/focus_radius", p.focus_radius)
