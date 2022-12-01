extends Node

const TIME_SECONDS = 5.0
const SUGAR_PER = 1
const REQUIRED_ENEMIES = 12

func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = TIME_SECONDS
	timer.one_shot = false
	timer.timeout.connect(
		func():
			var count = (len(get_tree().get_nodes_in_group("enemy")) / REQUIRED_ENEMIES) * SUGAR_PER
			Storage.player.currency_container.add(count)
	)
	timer.start()
