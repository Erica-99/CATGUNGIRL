extends StaticBody3D

@onready var Cell_Anims = $AnimationPlayer

func _ready() -> void:
	Cell_Anims.play("Cell_IdleOpen")
