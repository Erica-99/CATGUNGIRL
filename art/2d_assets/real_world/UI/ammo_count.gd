extends Control

@onready var ui_bullet_icon = preload("res://art/2d_assets/real_world/UI/bullet_icon.tscn")

@onready var VBOX = $ColorRect/MarginContainer/VBoxContainer

var CurrentAmmo = 20
var TargetAmmo = 10

signal bulletlost

func _process(delta: float) -> void:
	CurrentAmmo = VBOX.get_child_count()
	if CurrentAmmo < TargetAmmo:
		var newbullet = ui_bullet_icon.instantiate()
		VBOX.add_child(newbullet)
	elif CurrentAmmo > TargetAmmo:
		bulletlost.emit()
		var deadbullet = VBOX.get_child(VBOX.get_child_count(-1))
		deadbullet.queue_free()
