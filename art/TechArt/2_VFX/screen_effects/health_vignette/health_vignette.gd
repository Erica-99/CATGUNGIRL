extends CanvasLayer
class_name HealthVignette

const COLOR_ALPHA := "shader_parameter/ColorParameter:a"

@export var low_health_rect: ColorRect
@export var damage_rect: ColorRect
@export_range(0.0, 1.0) var low_health_threshold := 0.6
@export_range(0.0, 1.0) var low_health_min_strength := 0.15
@export_exp_easing var low_health_curve := 1.0
@export var low_health_fade := 0.4
@export var damage_flash_time := 0.35
@export var damage_breathing := false

var _max_health := 0.0
var _low_health_tween: Tween
var _damage_tween: Tween

func _ready() -> void:
	low_health_rect.material = low_health_rect.material.duplicate()
	damage_rect.material = damage_rect.material.duplicate()
	damage_rect.material.set_shader_parameter("toggle_breathing", damage_breathing)
	_set_alpha(low_health_rect, 0.0)
	_set_alpha(damage_rect, 0.0)

	var player := get_tree().get_first_node_in_group("player")
	if player:
		var health: HealthComponent = player.get_node("HealthComponent")
		_max_health = health.max_health
		_update_low_health(health.current_health)
	EventManager.player_health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(old_health: float, new_health: float, damage: DamageHealInstance) -> void:
	if new_health < old_health and damage.type != Enums.DamageType.DECAY:
		_flash_damage()
	_update_low_health(new_health)

func _flash_damage() -> void:
	if _damage_tween:
		_damage_tween.kill()
	_set_alpha(damage_rect, 1.0)
	_damage_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_damage_tween.tween_property(damage_rect.material, COLOR_ALPHA, 0.0, damage_flash_time)

func _update_low_health(health: float) -> void:
	if _low_health_tween:
		_low_health_tween.kill()
	_low_health_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_low_health_tween.tween_property(low_health_rect.material, COLOR_ALPHA, _low_health_strength(health), low_health_fade)

func _low_health_strength(health: float) -> float:
	var health_ratio := health / _max_health
	if health_ratio >= low_health_threshold:
		return 0.0
	var danger := 1.0 - health_ratio / low_health_threshold
	return lerpf(low_health_min_strength, 1.0, ease(danger, low_health_curve))

func _set_alpha(rect: ColorRect, alpha: float) -> void:
	rect.material.set_indexed(COLOR_ALPHA, alpha)
