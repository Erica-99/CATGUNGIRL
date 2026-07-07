extends Gun

func _shoot(damage, bullet_scale):
	_spawn_bullet(damage, bullet_scale * 1.5)

func _handle_special(input_state: Dictionary, delta: float) -> void:
	var charge_fire_held = input_state.get("charge_fire_held", false)
	
	if charge_fire_held:
		if not _is_charging:
			_is_charging = true
			_charge_timer = 0.0
			_is_perfect_charge = _is_aim_settled() and _time_since_last_shot < perfect_shot_max_interval
			charge_started.emit()
		var charge_delta = delta
		if _is_perfect_charge:
			charge_delta *= perfect_charge_multiplier
			# print("perfect charge active, charge_delta: ", charge_delta, " progress: ", _charge_progress)
		_charge_timer += charge_delta
		_charge_progress = clampf(
			(_charge_timer - hold_charge_min) / (hold_charge_max - hold_charge_min),
			0.0, 1.0
		)
		charge_progress_changed.emit(_charge_progress)
		_charge_timer = minf(_charge_timer, hold_charge_max)
	
	if not charge_fire_held and _is_charging:
		if _charge_timer >= hold_charge_min:
			_is_perfect_charge = false
			_fire_beam(_charge_progress)
		else:
			_is_charging = false
			_charge_timer = 0.0
			_is_perfect_charge = false
			charge_ended.emit()

# originally was global (in terms of gun-global) moved here for now
# want to use for multiple guns? move this function to gun - itll work the same :D
func _fire_beam(progress: float) -> void:
	_is_charging = false
	_charge_timer = 0.0
	_charge_progress = 0.0
	charge_ended.emit()
	if muzzle == null:
		return
		
	var space_state = get_world_3d().direct_space_state
	var from = muzzle.global_position
	var aim_dir = Vector3(cos(rotation.z), sin(rotation.z), 0.0).normalized()
	var to = from + aim_dir * beam_range
	
	var exclusions: Array[RID] = []
	var hit_enemies: Array = []
	var hit_hurtboxes: Array = []
	var beam_end = to
	
	while true:
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_areas = true
		query.collision_mask = 9 # layer 1 (geometry) + layer 4 (hurtboxes)
		query.exclude = exclusions
		var result = space_state.intersect_ray(query)
		
		if result.is_empty():
			break
		
		var collider = result["collider"]
		exclusions.append(result["rid"])
		
		if collider is Area3D:
			var enemy_root = collider.get_parent()
			if enemy_root in hit_enemies:
				continue
			hit_enemies.append(enemy_root)
			hit_hurtboxes.append(collider)
		else:
			beam_end = result["position"]
			break
			
	beam_fired.emit(beam_end, progress)
	_recoil_offset += recoil_amount * charged_recoil_multiplier * progress * sign(global_transform.basis.x.x)
	# AudioManager.play_sfx("")
	
	var damage = lerpf(beam_damage_min, beam_damage_max, progress)

	for hurtbox in hit_hurtboxes:
		var temp_hitbox = HITBOX_SCENE.instantiate()
		var damage_instance = DamageHealInstance.new()
		damage_instance.amount = damage
		damage_instance.is_heal = false
		damage_instance.type = Enums.DamageType.NORMAL
		damage_instance.knockback = bullet_knockback
		damage_instance.source = get_path()
		temp_hitbox.damage_or_heal_instance = damage_instance
		temp_hitbox.team_component = team_component
		temp_hitbox.hurtbox_hit.connect(func(hurtbox_hit): enemy_hit.emit(hurtbox_hit))
		hurtbox.take_hit(temp_hitbox)
		temp_hitbox.free()
