extends Node

const GUN_MAPPING: Dictionary = {
	"PISTOL": preload("res://scenes/components/gun_poc/pistol/pistol.tscn"),
	"SHOTGUN": preload("res://scenes/components/gun_poc/shotgun/shotgun.tscn"),
	"SNIPER": preload("res://scenes/components/gun_poc/sniper/sniper.tscn"),
}

func _get_gun_reference_from_enum(gun: Enums.Guns) -> PackedScene:
	return GUN_MAPPING[Enums.Guns.find_key(gun)]
