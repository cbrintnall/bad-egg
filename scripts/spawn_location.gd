extends Node2D

@onready var player = $AudioStreamPlayer2D
@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var spawn_time = Storage.game_settings.get_value("enemy", "spawn_time", 4.0)

var timer: SceneTreeTimer
var total_time: float

func _ready():
	add_to_group("spawn_location")

func spawn_in(enemy: PackedScene):
	total_time = spawn_time
	timer = get_tree().create_timer(spawn_time)
	timer.timeout.connect(
		func():
			var new_enemy = enemy.instantiate()
			new_enemy.global_position = global_position
			Storage.spawner.add_child(new_enemy)
			visible = false
			player.play()
			await player.finished
			queue_free()
	)

func _process(delta):
	animation_player.playback_speed = 1.0 + ((1.0-(timer.time_left/total_time))*2.0)
