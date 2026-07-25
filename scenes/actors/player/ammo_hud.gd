extends Node3D


#hey since this is wachowski spaghetti code I will attempt to explain my process
# as much as possible in case a programmer is unfortunately tasked with sifting through
# my shit lol!
#@onready var BulletIcon = preload("res://art/2d_assets/real_world/UI/bullet_icon.tscn")
@onready var BulletFX = preload("res://art/2d_assets/real_world/UI/bullet_count_VFX.tscn")
@onready var FXNode = $Sprite3D/FXNode
#I want the HUD to track how many bullets are currently visible on the hud (BulletCount)
# While comparing it to how many bullets are actually in the gun (TargetBullets)
#This way I can chain together faster animations of bullets moving into the gun when many
# bullets leave or enter the gun at once.
var TargetBullets
var BulletCount

func _ready() -> void:
	EventManager.enable_gun_ui.connect(func(enabled): visible = enabled)


func _on_ammo_count_bulletlost() -> void:
	var BulletDebri = BulletFX.instantiate()
	FXNode.add_child(BulletDebri)
	pass # Replace with function body.
