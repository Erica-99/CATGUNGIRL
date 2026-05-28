extends StaticBody3D

@export var level_end: Area3D

var unlocked_colour

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	##Create the unlocked colour for door lights
	unlocked_colour = StandardMaterial3D.new()
	unlocked_colour.albedo_color = Color(0 ,1.0, 0)
	unlocked_colour.emission_color = Color(0, 1.0, 0)
	
	##Don't allow the player to progress until all enemies are cleared
	#level_end.monitoring = false

func _change_door_lighting():
	$EXITHERECYLINDER.material_override = unlocked_colour
	$EXITHERECYLINDER2.material_override = unlocked_colour


func _on_enemy_manager_stage_cleared() -> void:
	_change_door_lighting()
	level_end.monitoring = true
