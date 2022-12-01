extends Resource
class_name Wave

enum Type {
	CHASER,
	MORTAR,
	SCATTER
}

var enemy_scene: PackedScene:
	get:
		return get_scene()
			
@export var enemy_type: Type

@export_range(0, 100) var amount: int = 1

var chaser := preload("res://scenes/enemy.tscn")
var peppa := preload("res://scenes/peppa.tscn")
var scatterer := preload("res://scenes/enemies/sausage.tscn")

var chaser_weight = Storage.game_settings.get_value("enemy", "chaser_difficulty", 1)
var mortar_weight = Storage.game_settings.get_value("enemy", "mortar_difficulty", 1)
var scatterer_weight = Storage.game_settings.get_value("enemy", "scatterer_difficulty", 1)

func get_scene() -> PackedScene:
	match enemy_type:
		Type.CHASER:
			return chaser
		Type.MORTAR:
			return peppa
		Type.SCATTER:
			return scatterer
			
	printerr("Couldn't get enemy for wave!")
	return null

func get_relative_difficulty() -> int:
	var difficulty = 1
	match enemy_type:
		Type.CHASER:
			difficulty = chaser_weight
		Type.MORTAR:
			difficulty = mortar_weight
		Type.SCATTER:
			difficulty = scatterer_weight

	return difficulty * amount

func wait_time() -> float:
	return get_relative_difficulty() * Storage.game_settings.get_value("round", "spawn_wait_multiplier", 2.0)
