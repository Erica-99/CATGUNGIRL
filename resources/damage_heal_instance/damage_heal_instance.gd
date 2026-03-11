class_name DamageHealInstance
extends Resource

@export var amount: float = 10.0
@export var is_heal: bool = false
@export var type: Enums.DamageType = Enums.DamageType.NORMAL
@export var knockback: float = 0.0
@export var source: NodePath
