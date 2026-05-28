extends InsanityEffect

@export var screen_pulse: ScreenPulseController

@export var insanity_low: ScreenPulsePreset
@export var insanity_high: ScreenPulsePreset

func change_effect_2() -> void:
	screen_pulse.apply_preset(insanity_low)

func change_effect_4() -> void:
	screen_pulse.apply_preset(insanity_high)
