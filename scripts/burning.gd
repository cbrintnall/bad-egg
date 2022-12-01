extends Node2D

var damage = StatInt.new("apply_burning", "damage", 1)
var tick_seconds = StatFloat.new("apply_burning", "tick_seconds", 1.0)

func _ready():
	tick_seconds.from_stream(
		func(val):
			$Timer.wait_time = val
	)
	
	$Timer.timeout.connect(
		func():
			get_parent().health.damage(damage.get_value())
	)
