extends Node3D

signal updatecameratween
signal removecameratween

@onready var cameratweentarget = $CameraTarget
var targetpos
@export var FOV = 75

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	targetpos = cameratweentarget.position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_area_entered(area: Area3D) -> void:
	
	pass # Replace with function body.
