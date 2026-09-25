extends Node3D

@export var speed_scale = 1.0

@onready var animation = $AnimationPlayer
@onready var crane = $Crane_Mesh_Collision
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	crane.sync_to_physics = true
	animation.speed_scale = speed_scale
	animation.play("moving")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
