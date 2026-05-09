extends Node

signal activate_popup(popup_id: int)
signal activate_date(date_id: int)

signal lockout_player_input
signal resume_player_input

signal enemies_active(is_active: bool)

signal enemy_killed()
signal player_hit_by_enemy()
signal current_killstreak(killstreak: int)
