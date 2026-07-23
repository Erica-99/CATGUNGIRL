extends Node

signal activate_popup(popup_id: int)
signal pre_date_sequence(date_id: int)
signal activate_date(date_id: int)

signal begin_date_scene_lock
signal end_date_scene_lock

signal increase_insanity_rank
signal insanity_changed(prev_rank: int, new_rank: int)

signal enemy_killed(enemy)
signal player_hit_by_enemy()
signal current_killstreak(killstreak: int)
signal gun_picked_up

signal player_health_initialised(init_current_health, init_max_health)
signal player_health_changed(old_health, new_health, damage_or_heal_instance)
signal player_interest_rank_changed(new_rank)

signal new_mag_loaded(ammo: int, capacity: int)
signal shot_fired
signal shots_loaded(shots: int)

signal new_gun_equipped(gun_name: String)

signal room_cleared(room_ID: Enums.Room, is_clear: bool)
signal spawn_enemy(custom_delay: float, spawner_path: NodePath)

signal start_elevator()

signal system_message(dialogue: String, message_status: bool)

signal shield_enabled_status(status: bool)

signal set_door_openable_state(door: Node3D, openable: bool)
