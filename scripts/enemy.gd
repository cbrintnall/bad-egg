extends CharacterBody2D
class_name Enemy

const drop_distance_range = 50.0

@export_node_path(Area2D) var health_path
@export var enemy_name: String

@onready var dropped_sugar_range = Storage.game_settings.get_value(enemy_name, "sugar_range", Vector2(1,3))
@onready var health = get_node(health_path)

var died_from_round_end = false
var sugar = preload("res://scenes/sugar.tscn")

func _ready():
	add_to_group("enemy")

	health.died.connect(
		func():
			_on_death(died_from_round_end)
	)

func _drop_sugar():
	var tree = get_tree()
	for i in range(randi_range(dropped_sugar_range.x,dropped_sugar_range.y)):
		var n = sugar.instantiate()
		n.global_position = global_position + (Utils.random_unit_circle() * drop_distance_range)
		tree.root.add_child(n)

func _on_death(died_from_round_end: bool):
	EventBus.enemy_died.emit(self)
	queue_free()

func kill_round_end():
	died_from_round_end = true
	health.execute()
