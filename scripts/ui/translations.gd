extends Node
class_name Translations

const translations_path = "res://configs/translations.cfg"
const missing_text_val = "!!UNKNOWN_TEXT!!"

var current_translation = "english"
var _translations := ConfigFile.new()

func _init():
	if _translations.load(translations_path) != OK:
		printerr("Failed to load translations")

func get_text(translation: String):
	var val = _translations.get_value(current_translation, translation, missing_text_val)

	if val == missing_text_val:
		printerr("Missing translation value for [%s/%s]" %[current_translation,translation])
		_translations.set_value(current_translation, translation, missing_text_val)
		_translations.save(translations_path)

	return val
	
