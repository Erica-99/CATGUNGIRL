extends BaseGun
@onready var muzzle: Marker3D = $Muzzle

func _direction_change(direction: float):
	muzzle.position.x *= -1
