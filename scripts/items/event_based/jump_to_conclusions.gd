extends Node

func _ready():
	Storage.spawner.end_round()
	queue_free()
