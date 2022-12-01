extends Item
class_name TowerItem

const target_entities: Array[String] = [
	"player",
	"tower"
]

var target_entity: String
var scene_to_apply: PackedScene
var _name: String

func _get_name():
	return _name

func _init(section_name: String, cfg: ConfigFile):
	_name = section_name
	super._init()
	var scene_path = cfg.get_value(section_name, "scene", "")
	var texture_path = cfg.get_value(section_name, "texture", "")
	target_entity = cfg.get_value(section_name, "target", "")
	scene_to_apply = load(scene_path) as PackedScene
	texture = load(texture_path) as Texture2D
	
	if not target_entity in target_entities:
		printerr("%s not a valid target " % [target_entity])
	_post_init()

func _post_init():
	pass

func _apply_effect(item, tower):
	pass

func purchase():
	super.purchase()
	
	EventBus.item_purchased.connect(_apply_effect)
