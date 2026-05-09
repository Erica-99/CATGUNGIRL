extends Node

signal activate_popup(popup_id: int)
signal activate_date(date_id: int)

signal lockout_player_input
signal resume_player_input

signal enemies_active(is_active: bool)

signal enemy_killed()
signal player_hit_by_enemy()
signal current_killstreak(killstreak: int)

signal player_health_initialised(init_current_health, init_max_health)
signal player_health_changed(old_health, new_health, damage_or_heal_instance)
signal player_insanity_gained(amount, buffer)
signal player_interest_rank_changed(new_rank)
