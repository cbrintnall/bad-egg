extends Node

func _process(delta):
	Storage.player.damage_multiplier.set_extra(1.0 - Storage.player.health.normalized)
