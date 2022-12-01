extends Node2D
class_name MapGenerator

const possible_directions = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

@export var chunk_size := Vector2i(10, 10)
@export var map_path: NodePath

@onready var map = get_node(map_path) as TileMap

var chunks := {}
var neighbor_directions = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

const chunk_scene = preload("res://scenes/map/chunk.tscn")
const sign_scene = preload("res://scenes/map/chunk_purchase.tscn")

var width:
	get: return chunk_size.x
var height:
	get: return chunk_size.y

func _ready():
	Storage.map_generator = self
	
	EventBus.round_end.connect(_generate_signs)
	EventBus.round_started.connect(_cleanup_signs)
	EventBus.game_over.connect(
		func(): 
			map.visible = false
			visible = false
	)

	generate_chunk(Vector2i.ZERO)

func _generate_signs():
	for chunk in chunks:
		for dir in neighbor_directions:
			if not (chunk+dir in chunks):
				var sign = sign_scene.instantiate()
				var rect = chunks[chunk].area as Rect2
				var spawn_position = Vector2.ZERO
				match dir:
					Vector2i.UP:
						spawn_position = Vector2((rect.position.x + rect.end.x)/2.0,rect.position.y)
					Vector2i.RIGHT:
						spawn_position = Vector2(rect.end.x-1, (rect.position.y + rect.end.y)/2.0)
					Vector2i.LEFT:
						spawn_position = Vector2(rect.position.x, (rect.position.y + rect.end.y)/2.0)
					Vector2i.DOWN:
						spawn_position = Vector2((rect.position.x + rect.end.x)/2.0, rect.end.y-1)
				add_child(sign)
				sign.global_position = Utils.tile_to_world(spawn_position, map)
				sign.chunk_to_purchase = chunk+dir
	
func _cleanup_signs(count):
	for node in get_tree().get_nodes_in_group("chunk_sign"):
		node.queue_free()

func generate_chunk(chunk: Vector2i):
	for x in range(chunk_size.x):
		for y in range(chunk_size.y):
			map.set_cell(0, Vector2((width*chunk.x)+x,(height*chunk.y)+y), 0, Vector2.ZERO)

	map.set_cells_terrain_path(0, map.get_used_cells(0), 0, 0, false)
	map.set_cells_terrain_connect(0, map.get_used_cells(0), 0, 0, false)
	
	var new_chunk = chunk_scene.instantiate()
	new_chunk.area = Rect2(chunk*chunk_size,chunk_size)
	add_child(new_chunk)
	chunks[chunk] = new_chunk
	
	var foliage_rect = new_chunk.area.grow(-1)
	
	for dir in possible_directions:
		if chunk + dir in chunks.keys():
			match dir:
				Vector2i.UP:
					foliage_rect = foliage_rect.grow_individual(0.0, 1.0, 0.0, 0.0)
				Vector2i.RIGHT:
					foliage_rect = foliage_rect.grow_individual(0.0, 0.0, 1.0, 0.0)
				Vector2i.LEFT:
					foliage_rect = foliage_rect.grow_individual(1.0, 0.0, 0.0, 0.0)
				Vector2i.DOWN:
					foliage_rect = foliage_rect.grow_individual(0.0, 0.0, 0.0, 1.0)
	
	var tiles = Utils.rect_to_tiles(foliage_rect)
	
	for i in range(randi_range(3, len(tiles))):
		var detail = Sprite2D.new()
		detail.texture = Storage.map_details.pick_random()
		detail.global_position = Utils.tile_to_world(tiles.pick_random(), map) + Vector2(randf() * map.tile_set.tile_size.x, randf() * map.tile_set.tile_size.y)
#		detail.rotation = deg_to_rad()
		detail.z_index = map.z_index+1
		add_child(detail)
