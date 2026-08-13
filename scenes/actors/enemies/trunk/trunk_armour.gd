extends Area3D
@onready var trunk: CharacterBody3D = $".."
@onready var shader_shield: MeshInstance3D = $ShaderShield
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var head_hurtbox: Area3D = $"../HeadHurtbox"

@export var team_component: Node
@export var hit_sfx_ref: String
@export var is_broken: bool = false
@export var break_sources: Array[String]

signal break_shield()

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(hitbox: Area3D) -> void:
	if team_component == null or hitbox.team_component == null:
		take_hit(hitbox)
	elif team_component.team != hitbox.team_component.team:
		take_hit(hitbox)
	else:
		return

## Handles taking damage by making callbacks to health component. Alerts the hitbox that a collision has occured.
# altered from original hurtbox component - just for armour
func take_hit(hitbox: Area3D) -> void:
	if hit_sfx_ref != "":
		AudioManager.play_sfx(hit_sfx_ref)
	hitbox.call("register_hit", self)
	if hitbox.damage_or_heal_instance != null:
		var break_hit_detected = false
		for source in break_sources:
			if source in str(hitbox.damage_or_heal_instance.source):
				break_hit_detected = true
		
		if break_hit_detected:
			break_shield.emit()
		
		#var dmg_heal_instance = hitbox.damage_or_heal_instance.duplicate()
		## apply damage multiplier to damage. ignore multipliers above 1.0 if damage is explosive since it doesnt make sense for explosive damage to headshot.
		#if dmg_heal_instance.type == Enums.DamageType.EXPLOSIVE:
			#dmg_heal_instance.amount *= clampf(damage_multiplier, 0, 1)
		#else:
			#dmg_heal_instance.amount *= damage_multiplier
		#health_component.take_damage_or_heal(dmg_heal_instance)
		#hitbox.call("register_damage_dealt", dmg_heal_instance.amount * float(not dmg_heal_instance.is_heal))
	


func _on_break_shield() -> void:
	is_broken = true
	collision_shape_3d.disabled = true
	shader_shield.visible = false
	head_hurtbox.damage_multiplier = 1.0
	trunk.state_machine.on_child_transition(trunk.state_machine.current_state, "trunkstun")
