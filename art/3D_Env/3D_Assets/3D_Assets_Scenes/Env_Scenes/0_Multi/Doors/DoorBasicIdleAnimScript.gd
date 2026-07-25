extends StaticBody3D

@onready var DoorBasic_Anims = $DoorBasic_AnimationPlayer

func _ready() -> void:
	
	DoorBasic_Anims.play("DoorBasic_IdleOpen")
