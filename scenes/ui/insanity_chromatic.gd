extends InsanityEffect

@export var chromatic: ChromaticController

func change_effect_1() -> void:
	chromatic.apply_aberration(Vector2(1,0),Vector2(0,0),Vector2(-1,0))

func change_effect_2() -> void:
	chromatic.apply_aberration(Vector2(2,0),Vector2(0,0),Vector2(-2,0))

func change_effect_3() -> void:
	chromatic.apply_aberration(Vector2(3,0),Vector2(0,0),Vector2(-3,0))

func change_effect_4() -> void:
	chromatic.apply_aberration(Vector2(4,0),Vector2(0,0),Vector2(-4,0))	

func change_effect_5() -> void:
	chromatic.apply_aberration(Vector2(5,0),Vector2(0,0),Vector2(-5,0))
