extends Area3D

@onready var TrunkScene

@onready var Cutsceneanim = $TrunkEventAnims




func _on_area_entered(area: Area3D) -> void:
	Cutsceneanim.play("TrunkSpawn")
	
	pass # Replace with function body.


func _on_trunk_event_anims_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'TrunkSpawn':
		Cutsceneanim.play("Broken")
		
	pass # Replace with function body.
