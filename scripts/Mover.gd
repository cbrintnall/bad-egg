extends Node2D

enum MovementType {
	TOWARDS_PLAYER,
	SCATTERED,
	IDLE
}

@export var satisfaction_distance := 20.0
@export var type := MovementType.TOWARDS_PLAYER
@export var stat_name: String

var speed: StatFloat
var target: CharacterBody2D
var target_tile := Vector2.ZERO
var _sprites := []

func _ready():
	speed = StatFloat.new(stat_name, "speed", 1000.0)
	
	_sync_parent()

func _sync_parent():
	var parent = get_parent()
	if parent is CharacterBody2D:
		target = parent
		_sprites = Utils.get_all_children_that(target, func(child): return child is Sprite2D)
	else:
		printerr("Mover's parent is not a CharacterBody2D!")
		queue_free()

func _process(delta):
	match type:
		MovementType.TOWARDS_PLAYER:
			_towards_player(delta)
		MovementType.SCATTERED:
			_scattered(delta)
		MovementType.IDLE:
			pass
			
func _towards_player(delta):
	var dir = global_position.direction_to(Storage.player.global_position)
	_move_towards(dir, delta)
	
func _scattered(delta):
	if target_tile == Vector2.ZERO:
		target_tile = Storage.spawner.get_random_tile()
	
	if global_position.distance_squared_to(target_tile) < satisfaction_distance:
		target_tile = Vector2.ZERO
	else:
		var dir = global_position.direction_to(target_tile)
		_move_towards(dir, delta)
	
func _move_towards(dir: Vector2, delta):
	target.move_and_collide(dir * speed.get_value() * delta)
