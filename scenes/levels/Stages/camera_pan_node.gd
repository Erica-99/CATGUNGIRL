extends Node3D

signal updatecameratween(NewCameraTarget,FOVtarget,RotationTarget)
signal removecameratween

@onready var cameratweentarget = $CameraTarget
var targetpos
var targetrot
@export var FOV = 0
@export var reset_on_exit = false
@export var Reset_Camera_on_Entry = false
@export var look_at_player = false
var targetposition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	targetpos = cameratweentarget.global_position
	targetrot = cameratweentarget.rotation
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_area_body_entered(body: Node3D) -> void:
	if Reset_Camera_on_Entry == false:
		print('area Entered')
		updatecameratween.emit(targetpos,FOV,targetrot,look_at_player)
	else:
		removecameratween.emit()
	pass # Replace with function body.


func _on_area_body_exited(body: Node3D) -> void:
	if reset_on_exit == true:
		removecameratween.emit()
	pass # Replace with function body.
