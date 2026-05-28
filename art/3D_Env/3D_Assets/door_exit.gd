extends StaticBody3D

var door_light_1
var door_light_2
var is_cleared
var unlocked_colour

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	door_light_1 = $EXITHERECYLINDER
	door_light_2 = $EXITHERECYLINDER2
	
	is_cleared = true
	
	unlocked_colour = StandardMaterial3D.new()
	unlocked_colour.albedo_color = Color(0 ,1.0, 0)
	unlocked_colour.emission_color = Color(0, 1.0, 0)

func _change_door_lighting():
	if is_cleared == true:
		door_light_1.material_override = unlocked_colour
