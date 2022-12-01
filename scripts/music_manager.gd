extends Node

var main_player: AudioStreamPlayer
var player_a := AudioStreamPlayer.new()
var player_b := AudioStreamPlayer.new()

const main_menu_music = preload("res://audio/music/Noire #1.mp3")
@onready var game_music = [load("res://audio/music/Do+Not+Look+Back.mp3"), load("res://audio/music/Memories.wav")]

func _ready():
	add_child(player_a)
	add_child(player_b)
	player_a.bus = "Music"
	player_b.bus = "Music"
	
	player_a.stream = main_menu_music
	player_a.play()
	main_player = player_a

	EventBus.in_main_menu.connect(func(): _cross_fade(main_menu_music, 0.1))
	EventBus.new_game.connect(func(): _cross_fade(game_music.pick_random(), 0.1))
	EventBus.game_over.connect(func(): _cross_fade(null, 0.1))

func _cross_fade(to: AudioStream, over: float):
	var tween = get_tree().create_tween()
	var other_player = player_b if main_player == player_a else player_a
	
	tween.tween_property(
		main_player,
		"volume_db",
		linear_to_db(0.0),
		over
	)

	tween.parallel()
	other_player.stream = to
	other_player.volume_db = linear_to_db(0.0)
	other_player.play()
	tween.tween_property(
		other_player,
		"volume_db",
		main_player.volume_db,
		over
	)

	tween.tween_callback(func(): main_player = other_player)
