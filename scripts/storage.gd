extends Node

var player: Player
var spawner: Spawner
var map_generator: MapGenerator
var game_flags := {}

var per_round_stats: PerRound
var translations := Translations.new()
var user_settings := ConfigFile.new()
var game_settings := ConfigFile.new()

var item_pool := WeightedPool.new() 
var weapon_pool := WeightedPool.new()

@onready var map_details = dir_contents("res://data/map/details", "AtlasTexture")

# Debug settings
var debug_actions = {}
var enemy_debug = {}
var debug_panel = {}
var debug_build := false
var debug = false:
	set(val):
		debug = val and debug_build
	get:
		return debug

func add_debug_action(key: int, action: Callable, description: String):
	debug_actions[key] = {
		"action": action,
		"description": description
	}

func change_flag(f, state):
	game_flags[f] = state
	EventBus.flag_changed.emit(f, state)

func flag_enabled(f) -> bool:
	return game_flags.get(f, false)

func _init():
	var err = game_settings.load("res://configs/global_settings.cfg")
	if err:
		printerr("ERROR LOADING GAME SETTINGS!")
		printerr(err)
		get_tree().quit(1)

	debug_build = "dev" in OS.get_cmdline_args()

func _unhandled_input(event):
	if event.is_action_pressed("debug_toggle"):
		debug = not debug
	if debug:
		if event is InputEventKey and event.is_pressed():
			if event.keycode in debug_actions.keys():
				debug_actions[event.keycode]["action"].call()

func get_random_item() -> Item:
	return item_pool.get_random()

func get_random_weapon() -> ItemWeapon:
	return null

func _on_new_game():
	per_round_stats = PerRound.new()

func _ready():
	add_child(translations)
	EventBus.new_game.connect(_on_new_game)
	
	_load_weapons()
	
	for item in _get_items():
		if item.can_spawn():
			item_pool.add(item)

		item.unlocked.connect(
			func():
				print("Item [%s] unlocked!" % item.item_name)
				item_pool.add(item)
		)

	print("Loaded [%d] items" % item_pool.count())

func _load_weapons():
	var weapons = dir_contents("res://data/weapons", "Resource")
	for weapon in weapons:
		weapon.load_stats()
	weapon_pool.add_many(weapons)

func _load_storage_items(path: String, cls):
	var cfg = ConfigFile.new()
	var err = cfg.load(path)
	if err:
		printerr("Error loading items: %d" % err)
	var items: Array[Item] = []
	for section in cfg.get_sections():
		print("Created item: %s" % section)
		var class_path = cfg.get_value(section, "class_path")
		var used_class = load(class_path) if class_path else cls 
		var item = used_class.new(section, cfg)
		items.push_back(item)
	return items

func _get_items() -> Array[Item]:
	var items: Array[Item] = []
	
	items.append_array(dir_contents("res://data/items", "Resource"))
#	items.append_array(_load_storage_items("res://configs/chance_items.cfg", _chance_to_apply_cls))
#	items.append_array(_load_storage_items("res://configs/tower_items.cfg", _tower_item_cls))
	
	for i in range(items.size()-1, -1, -1):
		if items[i] == null:
			items.remove_at(i)
		else:
			items[i].load_stats()

	return items

func dir_contents(path, type_hint := "") -> Array:
	var dir = DirAccess.open(path)
	var contents: Array = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = "%s/%s" % [path,file_name]
			if dir.current_is_dir():
				contents.append_array(dir_contents(full_path))
			else:
				if not ResourceLoader.exists(full_path):
					printerr("Troubles loading resource at path: %s" % full_path)
				var item = ResourceLoader.load(full_path, type_hint)
				contents.push_back(item)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return contents
