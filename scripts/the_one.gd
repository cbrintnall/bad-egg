extends CharacterBody2D

func _ready():
	add_to_group("round_cleanup")
	($Health as Health).died.connect(
		func():
			Storage.player.ui.stat_upgrades.available_points += 1
			queue_free()
	)
