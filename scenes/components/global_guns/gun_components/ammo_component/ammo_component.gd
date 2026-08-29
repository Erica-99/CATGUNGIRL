extends Node3D

@export_group("Ammo")
@export var ammo_max: int = 10
@export var reload_time: float = 3.0
@export var reload_full: bool = true 	# differentiates full mag reloaders (pistol)
										# and single shot reloaders (shotgun)

## Reload timer (can be replaced with programmatical timer as needed)
@onready var reload_timer: Timer = $ReloadTimer
@onready var _current_ammo: int = ammo_max

var single_reload_timer: float = 0 # to control changing reload times (e.g. 1.0 -> 0.5 -> 0.5 -> 0.5)
var _is_reloading: bool = false

func _handle_ammo():
	_current_ammo -= 1
	if _current_ammo <= 0 and reload_full: 
		_is_reloading = true
		reload_timer.start(reload_time)
