extends Resource
class_name Item

signal unlocked

var unknown_texture = preload("res://textures/unknown.tres")

@export var texture: Texture2D:
	set(t): texture = t
	get: return texture if texture else unknown_texture
@export var exported_name: String
@export var required_flag: Utils.Flag
@export var unlocked_by_default := true

var cost: StatInt
var spawn_chance: StatFloat
var item_name: String:
	get:
		return Storage.translations.get_text("%s_name" % exported_name)
var name:
	get:
		return item_name if item_name else _get_name()

# Stats are loaded after init since exported variables won't be available
func load_stats():
	cost = StatInt.new(exported_name, "cost", 0.0)
	spawn_chance = StatFloat.new(exported_name, "spawn_chance", 0.0)
	
	EventBus.flag_changed.connect(
		func(flag, state):
			if flag == required_flag and state:
				unlocked.emit()
	)
	
	_validate_necessary_text()

func _validate_necessary_text():
	var translations_keys = [
		"%s_description" % exported_name,
		"%s_name" % exported_name
	]
	
	for key in translations_keys:
		Storage.translations.get_text(key)

func can_purchase() -> bool:
	return true

func can_spawn() -> bool:
	return unlocked_by_default

func _get_name():
	return exported_name if exported_name else "Unknown"

func purchase():
	Storage.player.currency_container.total -= cost.get_value()
	Storage.player.pickup_item(self)
