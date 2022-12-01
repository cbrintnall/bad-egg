extends Node2D

var one = preload("res://scenes/the_one.tscn")

func _ready():
	EventBus.round_started.connect(
		func(num):
			add_child(one.instantiate())
	)
