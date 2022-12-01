extends Item
class_name ChanceToApply

const trigger_conditions: Array[String] = [
	"player_attack"
]

const target_entities: Array[String] = [
	"player",
	"enemy"
]

var apply_chance: StatFloat
var scene_to_apply: PackedScene
var trigger_condition: String
var target_entity: String

func load_stats():
	apply_chance = StatFloat.new(name, "apply_chance", 0.0)
	var scene_path = Storage.game_settings.get_value(name, "scene")
	var texture_path = Storage.game_settings.get_value(name, "texture")
	target_entity = Storage.game_settings.get_value(name, "target", "player")
	trigger_condition = Storage.game_settings.get_value(name, "trigger_condition", "player_attack")
	scene_to_apply = load(scene_path) as PackedScene
	texture = load(texture_path) as Texture2D

	if apply_chance.get_value() == 0.0:
		printerr("Apply chance for %s is 0.0%" % apply_chance.get_debug_str())
		
	if not (trigger_condition in trigger_conditions):
		printerr("%s is not a valid trigger condition" % trigger_condition)

func purchase():
	super.purchase()
	match trigger_condition:
		"player_attack":
			if target_entity == "player":
				EventBus.player_attacked.connect(
					func(enemy):
						var scene = scene_to_apply.instantiate()
						if randf() < apply_chance.get_value():
							scene.global_position = Storage.player.global_position
							Storage.player.get_tree().root.add_child(scene)
				)
			elif target_entity == "enemy":
				EventBus.player_attacked.connect(
					func(enemy):
						var scene = scene_to_apply.instantiate()
						if randf() < apply_chance.get_value():
							scene.global_position = enemy.global_position
							enemy.get_tree().root.add_child(scene)
				)
