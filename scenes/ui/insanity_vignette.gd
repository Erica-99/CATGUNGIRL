extends InsanityEffect

@export var vignette: VignetteController

@export var insanity_low: VignettePreset
@export var insanity_high: VignettePreset

func change_effect_1() -> void:
	vignette.apply_preset(insanity_low)

func change_effect_3() -> void:
	vignette.apply_preset(insanity_high)
