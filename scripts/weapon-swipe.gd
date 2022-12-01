extends WeaponMelee
class_name SwipeWeapon

@export_range(0, 360.0) var swing_intensity := .5
@export_range(0.0, 180.0) var weapon_swing_distance := 180.0

@onready var attack_timer = $AttackTimer as Timer

var cd_cache := {}

###
### Determines how far the weapon swings. Is determined by how many
### MELEE weapons the parent is currently holding.
###
func _get_swing_bounds() ->  Vector2:
	var dir_to_enemy = global_position.direction_to(current_target.global_position)
	var deg = rad_to_deg(atan2(dir_to_enemy.y,dir_to_enemy.x))
	return Vector2(deg-weapon_swing_distance ,deg+weapon_swing_distance)

func _can_attack() -> bool:
	return super._can_attack() and attack_timer.is_stopped()

func _attack():
	attack_timer.start()
	var tweener = get_tree().create_tween()
	var swing_bounds = _get_swing_bounds()

	tweener.tween_property(
		self,
		"position",
		Utils.deg_to_dir(swing_bounds.x) * WEAPON_DISTANCE,
		attack_timer.time_left*.1
	)

	tweener.tween_callback(func(): damager.enabled = true)

	tweener.tween_method(
		_set_position_from_degrees,
		swing_bounds.x,
		swing_bounds.y,
		attack_timer.time_left*.9
	).set_trans(Tween.TRANS_CUBIC)
	
	tweener.tween_callback(_attack_finished)
