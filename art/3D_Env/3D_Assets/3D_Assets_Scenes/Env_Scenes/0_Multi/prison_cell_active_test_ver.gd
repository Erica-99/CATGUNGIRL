extends StaticBody3D

#@onready var Cell_Anims = $AnimationPlayer
@export var cell_anim_player: AnimationPlayer

func _ready() -> void:
	cell_anim_player.play("Cell_IdleClosed")
