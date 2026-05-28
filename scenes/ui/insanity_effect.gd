extends Node
class_name InsanityEffect

func _ready() -> void:
	EventManager.insanity_changed.connect(update_effect)
	update_effect(null, Globals.global_insanity_level)
	alt_ready()

func update_effect(prev_rank, new_rank) -> void:
	match new_rank:
		0:
			pass
		1:
			change_effect_1()
		2:
			change_effect_2()
		3:
			change_effect_3()
		4:
			change_effect_4()
		5:
			change_effect_5()
		_:
			print("invalid insanity level")

func change_effect_1() -> void:
	pass

func change_effect_2() -> void:
	pass

func change_effect_3() -> void:
	pass

func change_effect_4() -> void:
	pass

func change_effect_5() -> void:
	pass

func alt_ready() -> void:
	pass
