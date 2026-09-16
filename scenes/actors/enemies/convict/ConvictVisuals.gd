extends Node3D

@onready var head_spr = $Sprite_Pivot/Body_PIV/Head_PIV/AnimatedSprite3D

func _ready() -> void:
	randomize()
	head_spr.frame = randi_range(0,27)
