extends HBoxContainer

@export_node_path(Node2D) var currency_tracker_path

@onready var currency_tracker = get_node(currency_tracker_path) as Node2D
@onready var label = $Label

func _ready():
	label.text = str(currency_tracker.total)

func _process(delta):
	label.text = str(currency_tracker.total)
