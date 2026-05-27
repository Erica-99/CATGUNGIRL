extends InsanityEffect

@export var vignette: VignetteController

func change_effect_1() -> void:
	vignette.apply_preset(vignette.insanity_low)

func change_effect_3() -> void:
	vignette.apply_preset(vignette.insanity_high)
