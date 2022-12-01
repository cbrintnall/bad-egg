extends Node
class_name Utils

enum Flag {
	NULL,
	CAT_PICKED_UP,
	CAT_HEAL
}

static func is_right(me: Node2D, them: Node2D) -> bool:
	var dot = me.global_position.direction_to(them.global_position).normalized().dot(Vector2.RIGHT)
	return dot >= 0.0

static func deg_to_dir(deg: float) -> Vector2:
	return Vector2(cos(deg_to_rad(deg)), sin(deg_to_rad(deg)))

static func random_unit_circle() -> Vector2:
	return Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	)

static func set_mode(node: Node, mode: int):
	node.process_mode = mode
	for child in node.get_children():
		set_mode(child, mode)

static func tile_to_world(tile: Vector2i, map: TileMap) -> Vector2:
	return map.to_global(map.map_to_local(tile))

static func rect_to_tiles(rect: Rect2) -> Array[Vector2i]:
	var l = []
	for x in range(rect.size.x):
		for y in range(rect.size.y):
			l.push_back(Vector2i(rect.position.x+x,rect.position.y+y))
	return l

static func get_all_children_that(node: Node, pred: Callable) -> Array:
	var b = []
	for child in node.get_children():
		if pred.call(child):
			b.push_back(child)
		b.append_array(get_all_children_that(child, pred))
	return b
