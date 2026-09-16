extends Node

var shields
var health

@export var health_bar : ProgressBar
@export var health_component: HealthComponent

@export_category("Boss Fight")
## Terminal instances in Stage 6
@export var terminals: Node3D
## Order and requirements of fight phases
@export var fight_phases: Array[BrainJarPhase] = []

var current_phase_index: int = 0
var activated_terminal_count: int = 0
var available_terminals: Array[Node] = []
var active_terminals: Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.shield_enabled_status.connect(_disable_shields)
	EventManager.brain_jar_terminal_activated.connect(_on_terminal_activated)
	
	shields = $Shields/CollisionShape3D
	health_bar.init_health(health)
	
	_enable_shields()
	call_deferred("_start_fight")

func _on_health_component_health_initialised(init_current_health: float, init_max_health: float) -> void:
	health = init_max_health

func _on_health_component_health_changed(old_health: float, new_health: float, damage_or_heal_instance: DamageHealInstance) -> void:	
	if ((old_health - new_health) > (health_bar.max_value / 5)) or ((old_health - new_health) < (health_bar.max_value / 5)):
		new_health = health - (health_bar.max_value / 5)
	
	health = new_health
	health_bar.health = health
	if health > 0:
		_enable_shields()
		EventManager.spawn_enemy.emit(0.1, get_path_to($"../EnemyManager/EnemySpawner"))
	else:
		# Play out death sequence (e.g. animations, cutscene)
		queue_free()

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
	
	var phase: BrainJarPhase = fight_phases[current_phase_index]
	
	activated_terminal_count = 0
	active_terminals.clear()
	
	var terminal_amount := mini(phase.terminal_count, available_terminals.size())
	
	for _i in range(terminal_amount):
		var terminal_group: BrainJarTerminalGroup = (available_terminals.pop_back() as BrainJarTerminalGroup)
		
		if terminal_group == null:
			continue
		
		var interactable: Node = (terminal_group.get_interactable_component())
		
		if interactable == null:
			push_warning(terminal_group.name +" has no interaction console assigned.")
			continue
		
		interactable.set("enabled", true)
		terminal_group.set_active_visual(true)
		active_terminals.append(terminal_group)

func _on_terminal_activated() -> void:
	activated_terminal_count += 1
	call_deferred("_update_terminal_visual_states")
	
	if activated_terminal_count >= active_terminals.size():
		_disable_shields()

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
