extends Node2D

const HOLD_DISTANCE = 120.0
const START_DEGREES = 0.0
const MAX_WEAPONS = 6

@export var target_area_path: NodePath
@export var weapon_distance := 1.0

@onready var target_area = get_node(target_area_path)

var targets := {}

func _ready():
	for child in get_children():
		child.lost_target.connect(
			func(target):
				if is_instance_valid(target):
					targets[target]={}
					targets[target]["distance"]=global_position.distance_squared_to(target.global_position)
		)
		
	target_area.connect("area_entered", _on_new_target)
	target_area.connect("area_exited", _remove_target)

	target_area.get_node("CollisionShape2D").shape.radius = _sync_area_range_to_weapons()*2.0

func _sync_area_range_to_weapons():
	var children = get_children()
	if len(children)> 0:
		return get_children().map(func(child): return child.get_check_range()).max()
	else:
		return 0.0

func pickup_weapon(item: ItemWeapon):
	if get_child_count() < MAX_WEAPONS:
		var new_weapon = item.weapon_scene.instantiate()
		add_child(new_weapon)

func find_target_for_weapon(weapon):
	var distance_order = []
	
	if len(targets) == 0:
		return weapon.current_target
	
	for target in targets:
		if target.has_method("is_dead") and not target.is_dead():
			distance_order.push_back([target, targets[target]["distance"]])

	distance_order.sort_custom(
		func(a,b):
			return a[1] < b[1]
	)
	
	if len(distance_order) == 0:
		return weapon.current_target
	
	if not weapon.current_target:
		return distance_order[0][0]
	
	var current_distance = weapon.current_target.global_position.distance_squared_to(global_position)
	for entry in distance_order:
		if entry[1] < current_distance:
			return entry[0]

	return weapon.current_target

func _process(delta):
	_update_targeting()

func _get_quadrant_for_node(node: Node2D):
	var dir = global_position.direction_to(node.global_position)
	var xs = sign(dir.x)
	var xy = sign(dir.y)
	if xs < 0.0:
		if xy < 0.0:
			return 1
		else:
			return 4
	else:
		if xy < 0.0:
			return 2
		else:
			return 3
	return -1

func _remove_target(target):
	targets.erase(target)

func _update_targeting():
	for target in targets:
		if not is_instance_valid(target):
			targets.erase(target)
			continue
		targets[target]["quadrant"] = _get_quadrant_for_node(target)
		targets[target]["distance"] = global_position.distance_squared_to(target.global_position)

func _on_new_target(area):
	if area.has_method("damage") and area.has_method("is_dead"):
		targets[area] = { "distance": global_position.distance_squared_to(area.global_position) }
		area.connect("died", func(): _remove_target(area))
		area.connect("tree_exited", func(): _remove_target(area))
