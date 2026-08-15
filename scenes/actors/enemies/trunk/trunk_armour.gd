extends Area3D
@onready var trunk: CharacterBody3D = $".."
@onready var shader_shield: MeshInstance3D = $ShaderShield
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var head_hurtbox: Area3D = $"../HeadHurtbox"

@export_category("Hitbox Details")
@export var team_component: Node
@export var hit_sfx_ref: String
@export var is_headshot: bool = false

@export_category("Armour Variables")
@export var is_broken: bool = false
@export var break_sources: Array[String]
@export var head_multiplier_on_break: float = 1.0

signal break_shield()

func _ready() -> void:
	# connect area check
	area_entered.connect(_on_area_entered)
	
	if is_broken:
		_break_shield()

# on area entered, take hit depending on team component match
func _on_area_entered(hitbox: Area3D) -> void:
	if team_component == null or hitbox.team_component == null:
		take_hit(hitbox)
	elif team_component.team != hitbox.team_component.team:
		take_hit(hitbox)
	return

## Handles taking damage by making callbacks to health component. Alerts the hitbox that a collision has occured.
# altered from original hurtbox component - just for armour
func take_hit(hitbox: Area3D) -> void:
	if hit_sfx_ref != "":
		AudioManager.play_sfx(hit_sfx_ref)
	hitbox.call("register_hit", self)
	if hitbox.damage_or_heal_instance != null:
		var break_hit_detected = false
		# break_sources define a string segment of a node path
		# this node path corresponds to the origin of a projectile emitted
		# as such "Sniper" as a break_source defines that bullets from "Sniper" shall break the shield
		# this is not the best way to do it, but it is currently the least invasive option
		# i'll rewrite this if we add more break_sources or change existing sources
		for source in break_sources:
			if source in str(hitbox.damage_or_heal_instance.source):
				break_hit_detected = true
		
		# emit signal here incase any other listening element in trunk node tree wants this signal (i.e., for shield display)
		if break_hit_detected:
			break_shield.emit()
		

# handle shield break
func _on_break_shield() -> void:
	# is_broken is a dead boolean - doesn't connect anywhere - this was added incase of future expansion - ill remove later if changes stop here
	is_broken = true
	_break_shield()
	
	# ADD ANIMATION SWITCH HERE
	
	# set recovery time to armour break recovery time (AFFECTS STUN IN TRUNKSTUN STATE)
	trunk.blackboard["recovery_time"] = trunk.blackboard["armour_break_recovery_time"]
	trunk.state_machine.on_child_transition(trunk.state_machine.current_state, "trunkstun")

# set variables for break
# disconnected from _on_break_shield() so it can be ran without sending trunk to trunkstun state
func _break_shield():
	collision_shape_3d.disabled = true
	shader_shield.visible = false
	head_hurtbox.damage_multiplier = head_multiplier_on_break
