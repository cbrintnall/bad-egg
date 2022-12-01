extends Sprite2D

var required_distance = 400.0

@export var pickup_sounds: Array[AudioStream] = []
@export var textures: Array[Texture2D] = []
@onready var player = $AudioStreamPlayer2D as AudioStreamPlayer2D

var move_speed = 0.0
const move_speed_increase_multiplier := 10.0
const pickup_distance = 75.0

func _ready():
	texture = textures[randi_range(0, len(textures)-1)]
	Storage.player.sugar_distance.from_stream(
		func(val):
			required_distance = val
	)
	
	EventBus.round_end.connect(queue_free)
	EventBus.game_over.connect(queue_free)

func _process(delta):
	var distance = Storage.player.global_position.distance_to(global_position)
	if distance < required_distance:
		move_speed += delta * move_speed_increase_multiplier
		global_position += global_position.direction_to(Storage.player.global_position) * move_speed
		if distance < pickup_distance and visible:
			visible = false
			Storage.player.currency_container.add(1)
			player.stream = pickup_sounds[randi_range(0,len(pickup_sounds)-1)]
			player.pitch_scale = randf_range(0.9, 1.1)
			player.play()
			player.finished.connect(queue_free)
