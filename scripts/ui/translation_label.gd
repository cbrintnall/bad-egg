extends Label

@export var key: String:
	get: return key
	set(val):
		text = Storage.translations.get_text(val)
		key = val
