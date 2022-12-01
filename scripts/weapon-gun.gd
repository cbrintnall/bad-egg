extends Weapon
class_name WeaponGun

@export_category("Gun")
@export var shoot_sounds: Array[AudioStream] = []
@export_node_path(Timer) var cooldown_timer_path
@export_node_path(Sprite2D) var sprite_path
@export_node_path(AudioStreamPlayer2D) var audio_player_path
@export_node_path(Node2D) var barrel_path

@onready var barrel = get_node(barrel_path) as Node2D
@onready var player = get_node(audio_player_path) as AudioStreamPlayer2D
@onready var sprite = get_node(sprite_path) as Sprite2D
@onready var cooldown_timer = get_node(cooldown_timer_path) as Timer

const bullet = preload("res://scenes/weapons/bullet.tscn")

func _ready():
	super._ready()
	
	set_meta("weapon_type", "ranged")
	
	cooldown_seconds.from_stream(
		func(val):
			cooldown_timer.wait_time = val
	)

func _process(delta):
	super._process(delta)
	
	if current_target:
		sprite.flip_v = global_position.direction_to(current_target.global_position).dot(Vector2.RIGHT) < 0.0

func _can_attack() -> bool:
	return super._can_attack() and cooldown_timer.is_stopped()

func _attack():
	cooldown_timer.start()
	player.stream = shoot_sounds[randi_range(0,len(shoot_sounds)-1)]
	player.play()
	var new_bullet = bullet.instantiate()
	new_bullet.reached_target.connect(_do_damage_to_target)
	new_bullet.global_position = barrel.global_position
	new_bullet.target = current_target
	get_tree().root.add_child(new_bullet)
