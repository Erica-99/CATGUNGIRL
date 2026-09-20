extends Node

enum FightState {
	TERMINALS,
	PLAYING_ANIMATION,
	WAITING_FOR_HEALING_HIT,
	HEALING_DAMAGE,
	WAITING_FOR_SACRIFICE,
	WAITING_FOR_DAMAGE,
	FINAL_VULNERABILITY,
	COMPLETE,
}

var shields
var health
var fight_state: FightState = FightState.TERMINALS

@export var health_bar : ProgressBar
@export var health_component: HealthComponent

@export_category("Boss Fight")
## Terminal instances in Stage 6
@export var terminals: Node3D
## Gun sacrifice object
@export var facility_core: Node3D
var gun_sacrifice_interactable: Node
## Order and requirements of fight phases
@export var fight_phases: Array[BrainJarPhase] = []

@export_category("Damage Healing")
@export var damage_heal_delay: float = 0.15
@export var damage_heal_duration: float = 0.75

@export_category("Boss Animation")
@export var boss_animation_player: AnimationPlayer
@export var intro_trigger: Area3D
@export var intro_animation_name: StringName
@export var after_four_terminals_animation_name: StringName

var intro_played: bool = false
var current_phase_index: int = 0
var activated_terminal_count: int = 0
var available_terminals: Array[Node] = []
var active_terminals: Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.shield_enabled_status.connect(_disable_shields)
	EventManager.brain_jar_terminal_activated.connect(_on_terminal_activated)
	EventManager.gun_sacrificed.connect(_on_gun_sacrificed)
	
	shields = $BrainJarJar/Shields/BrainJar_Collision
	health_bar.init_health(health)
	
	if intro_trigger != null and !intro_trigger.body_entered.is_connected(_on_intro_trigger_body_entered):
		intro_trigger.body_entered.connect(_on_intro_trigger_body_entered)
	
	if facility_core != null:
		gun_sacrifice_interactable = facility_core.get_node_or_null("FacilityCore_Mesh/InteractableComponent")

	if gun_sacrifice_interactable == null:
		push_error("Could not find the Facility Core InteractableComponent.")
	
	_set_gun_sacrifice_enabled(false)
	_enable_shields()

func _on_health_component_health_initialised(init_current_health: float, init_max_health: float) -> void:
	health = init_max_health

func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:
	if damage_or_heal_instance.is_heal:
		_update_health_display(new_health)
		return
	
	if fight_state == FightState.TERMINALS or fight_state == FightState.PLAYING_ANIMATION or fight_state == FightState.WAITING_FOR_SACRIFICE or fight_state == FightState.HEALING_DAMAGE or fight_state == FightState.COMPLETE:
		health_component.current_health = old_health
		
		if fight_state != FightState.HEALING_DAMAGE:
			_update_health_display(old_health)
	
		return
	
	match fight_state:
		FightState.WAITING_FOR_HEALING_HIT:
			_play_damage_heal(new_health, old_health)
		
		FightState.WAITING_FOR_DAMAGE:
			var controlled_health: float = _apply_damage_segment(old_health)
			
			if controlled_health <= health_component.min_health:
				_finish_fight()
			else:
				_advance_phase()
		
		FightState.FINAL_VULNERABILITY:
			var controlled_health: float = _apply_damage_segment(old_health)
			
			if controlled_health <= health_component.min_health:
				_finish_fight()

func _apply_damage_segment(old_health: float) -> float:
	var segment_damage: float = health_component.max_health / 5.0
	var controlled_health: float = maxf(old_health - segment_damage, health_component.min_health)
	
	health_component.current_health = controlled_health
	_update_health_display(controlled_health)
	return controlled_health

func _update_health_display(new_health: float) -> void:
	health = new_health
	health_bar.health = health

func _play_damage_heal(damaged_health: float, restored_health: float) -> void:
	fight_state = FightState.HEALING_DAMAGE
	
	# Restore the real health immediately so hit dosnt kill boss
	health_component.current_health = restored_health
	
	# Display damage before visually healing
	_update_health_display(damaged_health)
	_enable_shields()
	
	var heal_tween: Tween = create_tween()
	heal_tween.tween_interval(damage_heal_delay)
	heal_tween.tween_method(_update_health_display, damaged_health, restored_health, damage_heal_duration)
	heal_tween.finished.connect(_advance_phase)

func _disable_shields(signal_val = false):
	if !signal_val:
		shields.disabled = true
		health_component.damageable = true

func _enable_shields():
	shields.disabled = false
	health_component.damageable = false
	EventManager.shield_enabled_status.emit(true)

func _start_fight() -> void:
	if terminals == null:
		push_error("Brain Jar terminal container has not been assigned")
		return
	
	if fight_phases.is_empty():
		push_error("The Brain Jar has no fight phases")
		return
	
	available_terminals.clear()
	
	for terminal in terminals.get_children():
		if terminal is BrainJarTerminalGroup:
			available_terminals.append(terminal)
	
	available_terminals.shuffle()
	_start_current_phase()

func _start_current_phase() -> void:
	if current_phase_index >= fight_phases.size():
		return
	
	fight_state = FightState.TERMINALS
	activated_terminal_count = 0
	active_terminals.clear()
	
	_enable_shields()
	_set_gun_sacrifice_enabled(false)
	
	for terminal in available_terminals:
		var terminal_group := terminal as BrainJarTerminalGroup
		
		if terminal_group == null:
			continue
		
		terminal_group.set_active_visual(false)
		
		var interactable: Node = terminal_group.get_interactable_component()
		
		if interactable != null:
			interactable.set("enabled", false)
	
	var terminal_choices: Array[Node] = available_terminals.duplicate()
	terminal_choices.shuffle()
	var phase: BrainJarPhase = fight_phases[current_phase_index]
	var terminal_amount: int = mini(phase.terminal_count, terminal_choices.size())
	
	for _i in range(terminal_amount):
		var terminal_group := terminal_choices.pop_back() as BrainJarTerminalGroup
		
		if terminal_group == null:
			continue
		
		var interactable: Node = terminal_group.get_interactable_component()
		
		if interactable == null:
			push_warning(terminal_group.name + " has no interaction console assigned.")
			continue
		
		var event_trigger: Node = interactable.get("event_trigger") as Node
		
		if event_trigger != null:
			event_trigger.call("activate")
		
		interactable.set("enabled", true)
		terminal_group.set_active_visual(true)
		active_terminals.append(terminal_group)

func _on_terminal_activated() -> void:
	if fight_state != FightState.TERMINALS:
		return
	
	activated_terminal_count += 1
	call_deferred("_update_terminal_visual_states")
	
	if activated_terminal_count >= active_terminals.size():
		_complete_terminal_phase()

func _update_terminal_visual_states() -> void:
	for terminal in active_terminals:
		var terminal_group := terminal as BrainJarTerminalGroup
		
		if terminal_group == null:
			continue
		
		var interactable: Node = (terminal_group.get_interactable_component())
		
		if interactable == null:
			continue
		
		if interactable.get("enabled") == false:
			terminal_group.set_active_visual(false)

func _complete_terminal_phase() -> void:
	var phase: BrainJarPhase = fight_phases[current_phase_index]
	
	match phase.completion_type:
		BrainJarPhase.CompletionType.DAMAGE_HEAL_AND_ADVANCE:
			_play_after_four_terminals_animation()
		
		BrainJarPhase.CompletionType.SACRIFICE_THEN_DAMAGE:
			fight_state = FightState.WAITING_FOR_SACRIFICE
			_set_gun_sacrifice_enabled(true)
		
		BrainJarPhase.CompletionType.FINAL_VULNERABILITY:
			fight_state = FightState.FINAL_VULNERABILITY
			_disable_shields()

func _on_gun_sacrificed(_gun_name: String) -> void:
	if fight_state != FightState.WAITING_FOR_SACRIFICE:
		return
	
	_set_gun_sacrifice_enabled(false)
	fight_state = FightState.WAITING_FOR_DAMAGE
	_disable_shields()

func _set_gun_sacrifice_enabled(enabled: bool) -> void:
	if gun_sacrifice_interactable == null:
		return
	
	gun_sacrifice_interactable.set("enabled", enabled)
	
	if !enabled:
		EventManager.system_message.emit("", false)
	
	var event_trigger: Node = gun_sacrifice_interactable.get("event_trigger") as Node
	
	if event_trigger != null:
		if enabled:
			event_trigger.call("activate")
		else:
			event_trigger.call("deactivate")

func _advance_phase() -> void:
	_set_gun_sacrifice_enabled(false)
	_enable_shields()
	current_phase_index += 1
	
	if current_phase_index >= fight_phases.size():
		return
	
	EventManager.spawn_enemy.emit(0.1, get_path_to($"../EnemyManager/EnemyDoorFrame"))
	_start_current_phase()

func _finish_fight() -> void:
	fight_state = FightState.COMPLETE
	_set_gun_sacrifice_enabled(false)
	EventManager.brainjar_killed.emit()
	queue_free()

func _on_intro_trigger_body_entered(body: Node3D) -> void:
	if intro_played or !body.is_in_group("player"):
		return
	
	intro_played = true	
	boss_animation_player.play(intro_animation_name)
	var finished_animation: StringName = await boss_animation_player.animation_finished
	
	if finished_animation == intro_animation_name:
		_start_fight()

func _play_after_four_terminals_animation() -> void:
	fight_state = FightState.PLAYING_ANIMATION
	_enable_shields()
	boss_animation_player.play(after_four_terminals_animation_name)
	var finished_animation: StringName = await boss_animation_player.animation_finished
	
	if finished_animation == after_four_terminals_animation_name:
		_open_healing_hit_window()

func _open_healing_hit_window() -> void:
	fight_state = FightState.WAITING_FOR_HEALING_HIT
	_disable_shields()
