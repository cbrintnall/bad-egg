extends ProgressBar

@export_node_path var health_path
@export_range(1.0, 10.0) var change_speed = 5.0

@onready var health = get_node(health_path)
@onready var label = $Label

func _ready():
	min_value = 0

func _process(delta):
	max_value = health.max_health
	value = health.current_health
	label.text = "%d/%d" % [health.current_health, health.max_health]
