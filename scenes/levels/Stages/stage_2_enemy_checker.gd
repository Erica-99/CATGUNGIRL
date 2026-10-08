extends Node

var room_one_clear = false
var room_three_clear = false


func _on_room_one_stage_cleared() -> void:
	room_one_clear = true
	do_check()


func _on_room_three_stage_cleared() -> void:
	room_three_clear = true
	do_check()

func do_check() -> void:
	if room_one_clear and room_three_clear:
		EventManager.stage_2_shotgun_ready_for_pickup.emit()
