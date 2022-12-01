extends Stat
class_name StatFloat

var extra_value: float:
	get:
		return extra_value
	set(val):
		extra_value = clamp(val, min, max)
		var next_value = get_value()
		value_changed.emit(next_value)

var scalar: float
var min: float
var max: float

func _init(section: String, key: String, default: Variant, scalar_key := "", _min := -INF, _max := INF):
	super._init(section, key, default)
	
	min = _min
	max = _max
	scalar = Storage.game_settings.get_value(section, scalar_key, 1.0)
	extra_value = 0.0

func at_max() -> bool:
	return get_value() >= max
	
func at_min() -> bool:
	return get_value() <= min

func with_scalar(amt) -> float:
	return amt * scalar

func to_display() -> String:
	return "%d" % (get_value() * 100.0)

func reset():
	extra_value = 0.0

func set_value(val):
	if val > base_value:
		extra_value = base_value - val
	else:
		extra_value = 0.0

func set_extra(val):
	extra_value = val

func incr(val):
	extra_value += val
	
func decr(val):
	extra_value -= val

func get_value() -> float:
	return super.get_value() + extra_value
