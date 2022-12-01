extends Node2D
class_name Spawner

# amount of rounds in between difficulty curve
const round_interval := 10
const pre_round_wait_seconds := 3
const waves_path = "res://data/waves/"

@export_node_path(TileMap) var tilemap_path
@export_node_path var map_generator_path
@export var game_waves: Array[Wave]
@export var win_sound: AudioStream
@export var round_start_sound: AudioStream
@export var difficulty_curve: Curve
@export var spawn_delay_curve: Curve

@onready var audio_player = $AudioStreamPlayer
@onready var map = get_node(tilemap_path) as TileMap
@onready var map_gen = get_node(map_generator_path) as MapGenerator
@onready var enemy_timer = $enemy
@onready var round_timer = $round as Timer
@onready var spawns_parent = $spawns
@onready var spawn_wait_multiplier = Storage.game_settings.get_value("round", "spawn_wait_multiplier", 2.0)
@onready var minimum_round_time = Storage.game_settings.get_value("round", "minimum_round_time", 30.0)
@onready var maximum_round_time = Storage.game_settings.get_value("round", "maximum_round_time", 30.0)
@onready var round_cap = Storage.game_settings.get_value("round", "round_time_cap", 120.0):
	set(val): 
		round_cap = val
		round_timer.wait_time = round_cap
	get: return round_cap

var round_count = 0
var max_stands = StatInt.new("map", "max_stands", 5)

var spawn_location = preload("res://scenes/spawn_location.tscn")
var enabled = false:
	set(val):
		enemy_timer.paused = not val
		enabled = val
	get:
		return enabled
var round_active:
	get:
		return not round_timer.is_stopped()
var round_difficulty:
	get:
		return ((round_interval * round_count) + (round_interval * difficulty_curve.sample((round_count % round_interval) / round_interval))/round_interval)
var _waves_by_difficulty: Array[Wave]
var _round_waves: Array[Wave]
var _wave_idx_tracker := 0

func _ready():
	add_to_group("spawner")
	round_timer.timeout.connect(_on_round_end)
	enemy_timer.timeout.connect(_do_wave)
	
	round_timer.wait_time = round_cap
	
	Storage.spawner = self
	Storage.debug_panel["Difficulty"] = func(): return str(round_difficulty)
	
	_waves_by_difficulty = Storage.dir_contents(waves_path)
	_waves_by_difficulty.sort_custom(
		func(a:Wave,b:Wave):
			return a.get_relative_difficulty() > b.get_relative_difficulty()
	)
	
	global_position = get_center_spawn()
	
	EventBus.game_over.connect(end_game)
	EventBus.new_game.emit()

func end_game():
	_cleanup_round_entities()
	visible = false

func end_round():
	_on_round_end()

func get_center_spawn() -> Vector2:
	return map_gen.chunks[Vector2i.ZERO].area.get_center()

func get_random_tile() -> Vector2:
	return _get_random_tile()

func _get_random_tile() -> Vector2:
	return _snap_to_map(_get_random_cell())

func _snap_to_map(vec: Vector2i) -> Vector2:
	return map.to_global(map.map_to_local(vec))

func _get_random_cell() -> Vector2i:
	var cells = map.get_used_cells(0)
	return cells.pick_random()

func _get_positions_cluster(amount: int) -> Array[Vector2]:
	var used_cells = map.get_used_cells(0)
	used_cells.shuffle()
	var tiles = []
	for i in range(amount-1):
		tiles.push_back(used_cells.pop_front())
	
	return tiles.map(_snap_to_map)

func _on_round_end():
	round_timer.stop()
	enemy_timer.stop()
	
	_cleanup_round_entities()

	_play_sound(win_sound)
	EventBus.round_end.emit()

func _cleanup_round_entities():
	var cleanup_nodes = []
	var tree = get_tree()

	cleanup_nodes.append_array(tree.get_nodes_in_group("spawn_location"))
	cleanup_nodes.append_array(tree.get_nodes_in_group("round_cleanup"))

	for node in cleanup_nodes:
		if is_instance_valid(node):
			node.queue_free()

	for enemy in tree.get_nodes_in_group("enemy"):
		if is_instance_valid(enemy):
			enemy.kill_round_end()

func _get_waves() -> Array[Wave]:
	var r: Array[Wave] = []
	var difficulty_total := 0
	for wave in _waves_by_difficulty:
		if wave.get_relative_difficulty() + difficulty_total <= round_difficulty:
			r.push_back(wave)
			difficulty_total+=wave.get_relative_difficulty()
	return r 

func _do_wave():
	EventBus.wave_start.emit()
	var wave = _round_waves[_wave_idx_tracker]
	spawn(wave)
	enemy_timer.wait_time = wave.wait_time()
	enemy_timer.start()
	_wave_idx_tracker = (_wave_idx_tracker+1)%len(_round_waves)

func _play_sound(stream: AudioStream):
	audio_player.stream = stream
	audio_player.play()

func _unhandled_input(event):
	if not Storage.player.health.is_dead() and not round_active and event.is_action_pressed("start_round"):
		incr_round()

func incr_round():
	if round_active:
		push_warning("Tried to increment round, but one is already active!")
		return

	_wave_idx_tracker = 0
	round_count += 1
	_round_waves = _get_waves()
	round_timer.start()
	_play_sound(round_start_sound)
	EventBus.round_started.emit(round_count)
	_do_wave()

func spawn(wave: Wave):
	for pos in _get_positions_cluster(wave.amount):
		var loc = spawn_location.instantiate()
		loc.global_position = pos
		spawns_parent.add_child(loc)
		loc.spawn_in(wave.enemy_scene)

