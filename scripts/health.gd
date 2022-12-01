extends Node2D
class_name Health

signal died
signal healed
signal damaged
signal dodged

@export var stat_category := ""
@export var max_health := 100
@onready var current_health = max_health :
	set (value):
		# don't allow setting health if we're already at 0
		if current_health == 0:
			return

		current_health = clampi(value, 0, max_health)
		
		if is_dead():
			died.emit()
	get:
		return current_health

var on_enemy:
	get:
		return get_parent().is_in_group("enemy")
var normalized:
	get:
		return float(current_health)/float(max_health)

var status_text = preload("res://scenes/status_text.tscn")
var dodge: StatFloat
var health: StatInt
var _pipeline: Array[Callable] = []

func _ready():
	dodge = StatFloat.new(stat_category, "base_dodge", 0.0, "dodge_stat_increase_scalar")
	health = StatInt.new(stat_category, "base_health", 1)
	
	health.from_stream(
		func(val):
			max_health = val
	)

func add_to_pipeline(cb: Callable):
	_pipeline.push_back(cb) 

func is_dead():
	return current_health <= 0

func damage(amt: int):
	if randf() < dodge.get_value():
		_create_text("Dodged!")
		dodged.emit()
		return

	var amount_of_damage = amt
	
	for entry in _pipeline:
		amount_of_damage = entry.call(amount_of_damage)
	
	amount_of_damage = max(amount_of_damage, 0)
	current_health -= amount_of_damage
	
	if amount_of_damage > 0:
		emit_signal("damaged")
		if on_enemy:
			EventBus.enemy_damaged.emit(get_parent())
	_create_text(str(amt))

func execute():
	current_health = 0

func heal(amt: int):
	current_health += amt
	emit_signal("healed")
	_create_text("+{0}".format([str(amt)]))

func _create_text(txt: String):
	var status = status_text.instantiate()
	status.text = txt
	status.global_position = global_position
	get_tree().root.add_child(status)
