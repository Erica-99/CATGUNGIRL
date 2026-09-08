extends Node3D

class_name AmmoComponent

# handles everything ammo and reload related
# attached to gun by default (forced) - guns must have ammo, what a surprise

# autoloads
@onready var reload_timer: Timer = $ReloadTimer
@onready var _current_ammo: int = ammo_max

# exports
@export var gun_link: BaseGun
@export_group("Ammo Settings")
@export var ammo_max: int = 10
@export var reload_time: float = 3.0
@export var reload_full: bool = true 	# differentiates full mag reloaders (pistol)
										# and single shot reloaders (shotgun)

# runtime vars
var single_reload_timer: float = 0 # to control changing reload times (e.g. 1.0 -> 0.5 -> 0.5 -> 0.5)
var _is_reloading: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if gun_link.team_component.team == Enums.Team.PLAYER:
		_process_player_reload(delta)
	
	else:
		_process_enemy_reload(delta)


func _process_player_reload(delta: float) -> void:
	if DebugManager.infinite_ammo:
		return
	
	if !reload_full:
		single_reload_timer += delta
		# reload one shot
		if single_reload_timer > reload_time:
			_current_ammo += 1
			single_reload_timer = reload_time / 2.0
			if gun_link.active and gun_link.team_component.team == Enums.Team.PLAYER:
				EventManager.shots_loaded.emit(1)



# handles enemy specific reload (alot simpler than player reload)
# checks ammo status and if it has fallen below a certain level, then begin reload timer
func _process_enemy_reload(delta: float) -> void:
	if !_is_reloading:
		if _check_if_can_shoot():
			_is_reloading = true
			reload_timer.start(reload_time)


# return whether can shoot or not - default input of 1 to handle all generic guns
# can be overriden to check whether additional ammo is needed to shoot (i.e. shotgun pellets)
func _check_if_can_shoot(required_to_shoot: int = 1) -> bool:
	if _current_ammo >= required_to_shoot:
		return true
	return false


func _handle_ammo():
	if DebugManager.infinite_ammo:
		_current_ammo = ammo_max
		
		if gun_link.active:
			EventManager.new_mag_loaded.emit(_current_ammo, ammo_max)
		return
	
	EventManager.shots_fired.emit(1)
	
	_current_ammo -= 1
	if _current_ammo <= 0 and reload_full: 
		_is_reloading = true
		reload_timer.start(reload_time)


func _handle_debug_infinite_ammo() -> void:
	if !DebugManager.infinite_ammo:
		return
	
	_is_reloading = false
	reload_timer.stop()
	single_reload_timer = 0.0
	
	if _current_ammo != ammo_max:
		_current_ammo = ammo_max
		
		if gun_link.active:
			EventManager.new_mag_loaded.emit(_current_ammo, ammo_max)

func _on_reload_timer_timeout() -> void:
	_is_reloading = false
	_current_ammo = ammo_max
	
	if gun_link.active and gun_link.team_component.team == Enums.Team.PLAYER: 
		EventManager.new_mag_loaded.emit(_current_ammo, ammo_max)
