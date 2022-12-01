extends Node2D
class_name Weapon

const WEAPON_DISTANCE = 240.0

signal lost_target(target: Area2D)

@export_category("Base Weapon")
@export_range(0.0, 50.0) var weapon_lerp_speed := 35.0
@export_range(0.0, 360.0) var weapon_rotation_offset := 90.0
@export var weapon_stat_name: String

@onready var required_range = StatFloat.new(weapon_stat_name, "range", 30)
@onready var base_damage = StatFloat.new(weapon_stat_name, "damage", 1)
@onready var cooldown_seconds = StatFloat.new(weapon_stat_name, "cooldown", 1.0)

var current_target: Area2D = null:
	set(val):
		if current_target != null and current_target != val:
			lost_target.emit(current_target)
		
		current_target = val
		
		if current_target:
			var on_death = func(): current_target = null
			
			current_target.tree_exited.connect(on_death)
			current_target.died.connect(on_death)
	get:
		return current_target

func get_check_range():
	return _get_required_distance()

func _do_damage_to_target(target: Node2D):
	if target.has_method("damage"):
		var info := DamageInfo.new()
		info.damage = base_damage.get_value()
		info.target = target
		info.weapon_dealing = self
		target.damage(Storage.player.do_damage_pipeline(info).damage)
		EventBus.player_attacked.emit(info)
	else:
		printerr("Target %s had no damage method, what gives!" % target.name)

func _ready():
	add_to_group("weapons")
	Storage.debug_panel["(WEAPON) \"%s\"" % name] = func():
		var variables = [
			current_target if current_target else "N/A",
			current_target.global_position.distance_to(global_position) if current_target else "N/A",
		]

		return """
		TARGET:%s
		DISTANCE-TO-TARGET:%s
		""" % variables
		
	call_deferred("_sub_stats")

func _sub_stats():
	Storage.player.weapon_speed.from_stream(
		func(val):
			cooldown_seconds.set_extra(val)
	)

func _get_required_distance():
	return WEAPON_DISTANCE + required_range.get_value()

func _process(delta):
	if _can_attack():
		_attack()
	else:
		_update_positioning(delta)
		current_target = get_parent().find_target_for_weapon(self)

func _get_aim_direction() -> Vector2:
	return Utils.deg_to_dir(_get_degree_position() * get_index())

func _set_position_from_degrees(degrees:float):
	position = Utils.deg_to_dir(degrees) * WEAPON_DISTANCE

func _get_degree_position() -> float:
	var children = get_parent().get_child_count()
	return (1.0/float(children)) * 360.0

func _can_attack() -> bool:
	return current_target != null
	
func _attack():
	pass
	
func _update_positioning(delta):
	if current_target:
		var dir = global_position.direction_to(current_target.global_position)
		var angle = atan2(dir.y, dir.x)

		global_rotation = angle + deg_to_rad(weapon_rotation_offset)

	position = lerp(position, _get_aim_direction().normalized() * WEAPON_DISTANCE, weapon_lerp_speed*delta)
