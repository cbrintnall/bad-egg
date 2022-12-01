extends Weapon
class_name WeaponMelee

@export_node_path(AudioStreamPlayer2D) var player_path
@export_node_path(Sprite2D) var sprite_path
@export_node_path(Timer) var cooldown_timer_path
@export_node_path var damager_path

@onready var player = get_node(player_path) as AudioStreamPlayer2D
@onready var damager = get_node(damager_path)
@onready var cooldown_timer = get_node(cooldown_timer_path) as Timer
@onready var sprite = get_node(sprite_path) as Sprite2D

func _ready():
	super._ready()
	
	set_meta("weapon_type", "melee")

	damager.signal_only = true
	damager.enabled = false
	damager.connect("damaged", 
		func(area): 
			player.play()
			_do_damage_to_target(area)
	)
	
	base_damage.from_stream(
		func(val):
			damager.damage = val
	)
	
	cooldown_seconds.from_stream(
		func(val):
			cooldown_timer.wait_time = val
	)

func _attack_finished():
	cooldown_timer.start()
	damager.enabled = false
	damager.reset()

func _get_aim_direction() -> Vector2:
	if current_target:
		return global_position.direction_to(current_target.global_position)
		
	return super._get_aim_direction()

func _can_attack() -> bool:
	if not current_target:
		return false

	if not cooldown_timer.is_stopped():
		return false 
		
	if global_position.distance_to(current_target.global_position) > _get_required_distance():
		return false

	return true
