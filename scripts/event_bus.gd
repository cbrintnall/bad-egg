extends Node

signal enemy_died(enemy)
signal enemy_damaged(enemy)
signal player_attacked(enemy)
signal item_purchased(item, stand)
signal item_stand_spawned(stand)
signal round_end
signal round_started(count)
signal wave_start
signal confirmed_points
signal flag_changed(flag, state)
signal new_game
signal game_over
signal in_main_menu
