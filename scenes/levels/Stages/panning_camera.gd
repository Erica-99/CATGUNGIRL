extends Node3D




@onready var camera = $Camera
@onready var player = $"../Player"
@onready var playerrotate = $Player_rotation_pivot
@export var default_offset = Vector3(0,20,45)
@export var CameraSpeed = 6

##The level of influence the target point has on the camera, 0 focuses on player, 1 focuses on target
@export var Player_Target_Ratio = 0.5


var looking_at_player = false
var targetpos
var targetfov
var playercam_pos
var enviroment_offset_active = false
var enviroment_offset_Value



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func gettargetposition():
	if enviroment_offset_active == false:
		playercam_pos = Vector3(player.position.x,player.position.y,player.position.z)
		targetpos = playercam_pos + default_offset
		return targetpos
	else:
		playercam_pos = Vector3(player.position.x,player.position.y,player.position.z)
		var playercamtarget = playercam_pos + default_offset
		targetpos = playercamtarget.lerp(enviroment_offset_Value,Player_Target_Ratio)
		return targetpos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	playerrotate.look_at(player.position)
	
	if looking_at_player == true:
		rotation = rotation.lerp(playerrotate.rotation,CameraSpeed * delta)
	else:
		rotation = rotation.lerp(Vector3(0,0,0), CameraSpeed * delta)
	targetpos = gettargetposition() 
	position = position.lerp(targetpos,CameraSpeed * delta)
	pass


func _on_camera_pan_node_updatecameratween(NewCameraTarget: Variant, FOVtarget: Variant, RotationTarget: Variant,is_looking_at_player) -> void:
	print(NewCameraTarget)
	looking_at_player = is_looking_at_player
	enviroment_offset_active = true
	enviroment_offset_Value = NewCameraTarget
	targetfov = 75 + FOVtarget
	var fov_tween = create_tween()
	fov_tween.tween_property(camera,'fov', targetfov,0.5)
	pass # Replace with function body.


func _on_camera_pan_node_removecameratween() -> void:
	enviroment_offset_active = false
	targetfov = 75
	looking_at_player = false
	pass # Replace with function body.
