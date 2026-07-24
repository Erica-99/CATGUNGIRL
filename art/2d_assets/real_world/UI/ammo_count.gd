extends Control

#@onready var ui_bullet_icon = preload("res://art/2d_assets/real_world/UI/bullet_icon.tscn")
@export var bullet_icons: Dictionary[String, PackedScene]

@onready var VBOX = $ColorRect/MarginContainer/VBoxContainer

signal bulletlost

var current_ammo_icon: PackedScene

func _ready() -> void:
	EventManager.new_mag_loaded.connect(_load_new_mag)
	EventManager.shots_fired.connect(_fire_shots)
	EventManager.shots_loaded.connect(_add_bullets)
	EventManager.new_gun_equipped.connect(_ammo_type_changed)


func _load_new_mag(ammo: int, mag_capacity: int) -> void:
	# Not currently using mag capacity but I've included it anyway
	
	# Clear old bullets without firing them
	for child in VBOX.get_children():
		child.queue_free()
	
	# Load new bullets
	for i in ammo:
		var newbullet = current_ammo_icon.instantiate()
		VBOX.add_child(newbullet)


func _fire_shots(shots: int) -> void:
	for i in range(shots):
		var deadbullet = VBOX.get_children()[-(i+1)]
		deadbullet.queue_free()
		bulletlost.emit()


func _add_bullets(bullets_to_add: int) -> void:
	for bullet in bullets_to_add:
		var newbullet = current_ammo_icon.instantiate()
		VBOX.add_child(newbullet)

func _ammo_type_changed(new_type: String) -> void:
	if new_type in bullet_icons.keys():
		current_ammo_icon = bullet_icons[new_type]
	else:
		bullet_icons.values()[0] # Just default to the first item (should be pistol ammo)
	
	VBOX.set_settings_for_gun(new_type)
