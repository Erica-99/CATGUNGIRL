extends Node3D

@onready var target_raycast: RayCast3D = $TargetPoint
@onready var wall_raycast: RayCast3D = $WallDetector
@onready var platform_raycast: RayCast3D = $PlatformDetector

@onready var detectors: Array[RayCast3D] = [target_raycast, wall_raycast, platform_raycast]

var _currently_enabled: bool = false

## Use to enable/disable the raycasts.
func set_checking_enabled(enabled: bool) -> void:
	for detector in detectors:
		detector.enabled = enabled
	_currently_enabled = enabled

## Check if it is possible to mantle
var can_mantle: bool:
	get:
		if not _currently_enabled:
			return false
		
		if (target_raycast.is_colliding() and platform_raycast.is_colliding() 
		and not wall_raycast.is_colliding()):
			return true
		else:
			return false

## Get the point to mantle to. Always check can_mantle first.
func get_target_mantle_point() -> Vector3:
	return target_raycast.get_collision_point()

## Update raycast positions when the player turns around.
func _on_player_facing_changed(new_facing: float) -> void:
	for detector in detectors:
		detector.position.x = new_facing*abs(detector.position.x)
		detector.target_position.x = new_facing*abs(detector.target_position.x)
