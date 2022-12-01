extends Resource
class_name Stat

signal value_changed(value)

var base_value
var _section: String
var _key:String

func _init(section: String, key: String, default: Variant):
	_section = section
	_key = key
	
	var val = Storage.game_settings.get_value(section, key)
	
	if not val:
		val = default
		printerr("Had to use default for stat [%s/%s]" % [section,key])
	
	base_value = val
	
func _storage_key() -> String:
	return "[%s/%s]" % [_section, _key]
	
func get_debug_str() -> String:
	return _storage_key()

func from_stream(cb: Callable):
	value_changed.connect(func(val): cb.call(get_value()))
	cb.call(get_value())

func get_value():
	return base_value
