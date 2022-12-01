extends HSlider

@export var bus: String

@onready var bus_idx = AudioServer.get_bus_index(bus)
@onready var setting = Setting.new("audio", bus, 0.5)

func _ready():
	min_value = 0.0
	max_value = 1.0
	value_changed.connect(
		func(val):
			setting.value = val
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(setting.value))
	)
	value = setting.value
