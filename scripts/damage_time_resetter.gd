extends Node2D

@export_node_path var damager
@export var time := 2.0

func _ready():
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = time
	var node = get_node(damager)
	timer.timeout.connect(
		func():
			node.reset()
	)
