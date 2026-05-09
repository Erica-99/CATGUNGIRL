extends Node

signal activate_popup(popup_id: int)
signal activate_date(date_id: int)

signal begin_date_scene_lock
signal end_date_scene_lock

signal enemies_active(is_active: bool)

signal increase_insanity_rank

signal enemy_killed()
signal player_hit_by_enemy()
signal current_killstreak(killstreak: int)
