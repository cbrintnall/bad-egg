extends Enemy

@export var seed_texture: Texture2D
@export_node_path var seed_spawn_path

@onready var seed_spawn = get_node(seed_spawn_path)
@onready var timer := $SeedShooter/Timer as Timer
@onready var animation := $AnimationPlayer as AnimationPlayer
@onready var shoot_speed_seconds := StatFloat.new(enemy_name, "shoot_speed_seconds", 2.5)
@onready var damage := StatInt.new(enemy_name, "damage", 1)
var bullet_scene = preload("res://scenes/seed_2.tscn")

func shoot_seed():
	var bullet = bullet_scene.instantiate()
	bullet.target = Storage.player
	bullet.area_entered.connect(
		func(target):
			if target.has_method("damage"):
				target.damage(damage.get_value())
				bullet.queue_free()
	)
	seed_spawn.add_child(bullet)
	bullet.position = Vector2.ZERO

func _ready():
	super._ready()

	timer.timeout.connect(func(): animation.play("Shoot"))

func _on_death(from_round_end: bool):
	if not from_round_end:
		_drop_sugar()
		
	super._on_death(from_round_end)
