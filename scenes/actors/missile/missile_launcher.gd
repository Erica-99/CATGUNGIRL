extends Node3D
class_name MissileLauncher

const MISSILE = preload("uid://bt57arw8qv0ya")

@onready var blaster_anims = $"../../Blaster_anims"

@export var spawn_cooldown: float = 2
@export var spawn_count: int = 1

var active: bool = false
var spawn_timer: float

func _process(delta: float) -> void:
	if active:
		spawn_timer += delta
		if spawn_timer > spawn_cooldown:
			spawn_timer = 0
			blaster_anims.play("Firing")


# Spawns new missile
func launch_missile() -> void:
	var new_missile = MISSILE.instantiate() as CharacterBody3D
	
	#Globals.current_scene_reference.add_child(new_missile)
	get_tree().current_scene.add_child(new_missile)
	new_missile.global_position = global_position

# Testing Scene Function Only
func _on_button_pressed() -> void:
	if active:
		turn_off()
	else:
		turn_on()

func turn_on() -> void:
	active = true
	spawn_timer = 0

func turn_off() -> void:
	active = false


func _on_blaster_anims_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'Firing':
		launch_missile()
		blaster_anims.play("Fired")
	if anim_name == 'Fired':
		blaster_anims.play("idle")
	pass # Replace with function body.
