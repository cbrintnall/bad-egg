extends Resource
class_name Setting

signal value_changed(val)

const settings_path = "user://settings.cfg"

var setting_name: String
var section: String

var value: Variant:
	get: return value
	set(val):
		value = val
		Storage.user_settings.set_value(section, setting_name, val)
		Storage.user_settings.save(settings_path)

func _init(_section: String, n: String, default: Variant):
	setting_name = n
	section = _section
	
	var err = Storage.user_settings.load(settings_path)

	if err == ERR_FILE_NOT_FOUND:
		Storage.user_settings.save(settings_path)
		print("Created new settings file!")
		
	value = Storage.user_settings.get_value(section, setting_name, default)
