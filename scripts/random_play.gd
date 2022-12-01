extends AudioStreamPlayer2D

var timer:Timer
var range := Vector2(1.0, 3.0)

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(
		func():
			play()
			timer.wait_time = randf_range(range.x,range.y)
	)
	timer.one_shot = false
	timer.start()
