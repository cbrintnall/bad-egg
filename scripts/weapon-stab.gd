extends WeaponMelee
class_name WeaponStab

@export var distance := 100.0
@export var buffer_distance := 50.0

@onready var attack_timer = $AttackTimer

func _get_required_distance() -> float:
	return distance

func _can_attack() -> bool:
	return super._can_attack() and attack_timer.is_stopped()

func _update_positioning(delta):
	if attack_timer.is_stopped():
		super._update_positioning(delta)

func _attack():
	attack_timer.start()
	var tween = get_tree().create_tween()
	var dir_to_target = global_position.direction_to(current_target.global_position)
	
	tween.tween_callback(func(): damager.enabled = true)
	tween.tween_property(
		self,
		"position",
		(dir_to_target * distance) + (dir_to_target * buffer_distance),
		attack_timer.time_left
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_callback(_attack_finished)
