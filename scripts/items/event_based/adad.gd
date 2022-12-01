extends Node

func _ready():
	EventBus.round_started.connect(
		func(count):
			Storage.player.currency_container.total += (Storage.player.currency_container.total * .1)
	)
	queue_free()
