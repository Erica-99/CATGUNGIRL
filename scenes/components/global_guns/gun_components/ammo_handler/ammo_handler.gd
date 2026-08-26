extends Node3D
# needs reference to parent for automatic signal assignment
@export var parent_reference: ImprovedGun = null

@export_group("Ammo")
@export var ammo_max: int = 10
@export var reload_time: float = 3.0
@export var reload_full: bool = true 	# differentiates full mag reloaders (pistol)
										# and single shot reloaders (shotgun)
var single_reload_timer: float = 0 # to control changing reload times (e.g. 1.0 -> 0.5 -> 0.5 -> 0.5)

@onready var _current_ammo: int = ammo_max
var _is_reloading: bool = false

func _process(delta: float) -> void:
	
	# single shot reloading
	if !reload_full:
		if _current_ammo != ammo_max:
			single_reload_timer += delta
			if single_reload_timer > reload_time:
				_current_ammo += 1
				single_reload_timer = reload_time / 2.0
				if parent_reference.active: EventManager.shots_loaded.emit(1)
	
	# in hindsight, the is_reloading should probably have a set of interactions for attempted bulletshots whilst reload but anyways...
	if !parent_reference.active:
		return
