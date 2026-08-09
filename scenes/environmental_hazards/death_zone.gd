extends Area3D

signal hurtbox_hit(hurtbox: Area3D)
signal damage_dealt(total_damage: float)

@export var damage_amount: float = 25.0
@export var instant_kill: bool = false
@export var team_component: Node

var damage_or_heal_instance: DamageHealInstance

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if !area.has_method("take_hit"):
		return
	
	var player = area.get_parent()
	
	if player == null:
		return
	
	if !player.is_in_group("player"):
		return
	
	var health_component: HealthComponent = player.get_node_or_null("HealthComponent")
	_create_damage_instance()
	
	if instant_kill:
		health_component.set_health_to_min()
	
	area.take_hit(self)

func _create_damage_instance() -> void:
	damage_or_heal_instance = DamageHealInstance.new()
	damage_or_heal_instance.amount = damage_amount
	damage_or_heal_instance.is_heal = false
	damage_or_heal_instance.type = Enums.DamageType.NORMAL
	damage_or_heal_instance.source = get_path()

func register_hit(hurtbox: Area3D) -> void:
	hurtbox_hit.emit(hurtbox)

func register_damage_dealt(damage: float) -> void:
	damage_dealt.emit(damage)
