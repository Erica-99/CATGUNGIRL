extends Node3D





@onready var player = $"../Player"

@export var default_offset = Vector3(0,20,45)

var playercam_pos
var targetpos


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func gettargetposition():
	playercam_pos = Vector3(player.position.x,player.position.y,player.position.z)
	targetpos = playercam_pos + default_offset
	return targetpos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	targetpos = gettargetposition()
	position = targetpos
	pass
