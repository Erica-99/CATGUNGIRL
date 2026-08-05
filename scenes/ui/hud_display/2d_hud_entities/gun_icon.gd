extends Control


@onready var anims = $GunAnimations
@onready var sprite = $Guns

var currentgun = 'Pistol'
var targetgun = 'Pistol'


func _ready() -> void:
	EventManager.new_gun_equipped.connect(_on_gun_swapped)
	EventManager.enable_gun_ui.connect(func(enabled): visible = enabled)


func _process(delta: float) -> void:
	currentgun = str(sprite.animation)
	if currentgun != targetgun:
		anims.play('GoAway')



func _on_gun_animations_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'GoAway':
		sprite.play(targetgun)
		anims.play("Return")
	elif anim_name == 'Return':
		anims.play('Idle')
	pass # Replace with function body.


func _on_gun_swapped(new_gun: String) -> void:
	targetgun = new_gun
