extends Node

signal activate_popup(popup_id: int)
signal activate_date(date_id: int)

signal begin_date_scene_lock
signal end_date_scene_lock

signal increase_insanity_rank

signal enemy_killed()
signal player_hit_by_enemy()
signal current_killstreak(killstreak: int)

signal player_health_initialised(init_current_health, init_max_health)
signal player_health_changed(old_health, new_health, damage_or_heal_instance)
signal player_insanity_gained(amount, buffer)
signal player_interest_rank_changed(new_rank)

signal room_cleared(room_ID: Enums.Room)
