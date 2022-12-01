extends Node2D
class_name Chunk

enum ChunkSpawnType {
	ITEM,
	WEAPON
}

var area: Rect2

@onready var item_chance = Storage.game_settings.get_value("chunk", "item_chance", 75.0)
@onready var weapon_chance = Storage.game_settings.get_value("chunk", "weapon_chance", 100.0-item_chance)
@onready var player = $AudioStreamPlayer
@onready var child_container = $Children

var _item_stand_scene = preload("res://scenes/item.tscn")
var _puff_scene = preload("res://scenes/puff.tscn")

func _ready():
	EventBus.round_started.connect(_do_spawn)
	EventBus.round_end.connect(_on_round_end)

func _on_round_end():
	for child in child_container.get_children():
		child.queue_free()
		var puff = _puff_scene.instantiate() as GPUParticles2D
		puff.global_position = child.global_position
		puff.emitting = true
		add_child(puff)
		player.play()
		await get_tree().create_timer(puff.lifetime).timeout
		puff.queue_free()

func _do_spawn(count: int):
	var center = Utils.tile_to_world(area.get_center(), Storage.map_generator.map)
	var new_stand = _item_stand_scene.instantiate()
	new_stand.global_position = center
	child_container.add_child(new_stand)

	var roll = randf_range(0, 100.0)
	var type = ChunkSpawnType.WEAPON
	if roll <= weapon_chance:
		type = ChunkSpawnType.WEAPON
	else:
		type = ChunkSpawnType.ITEM

	if type == ChunkSpawnType.ITEM:
		new_stand.item_grabber = func(): return Storage.item_pool.get_random()
	elif type == ChunkSpawnType.WEAPON:
		new_stand.item_grabber = func(): return Storage.weapon_pool.get_random()
 
