extends Node

signal activate_popup(popup_id: int)
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

signal room_cleared(room_ID: Enums.Room, is_clear: bool)
signal spawn_enemy(custom_delay: float, spawner_path: NodePath)

signal start_elevator()

signal system_message(dialogue: String, message_status: bool)

signal shield_enabled_status(status: bool)
