extends CharacterBody2D
class_name Player

@export var body_weapon_distance := 1.0

@onready var currency_container = $Currency
@onready var weapon_holder := $Body/WeaponHolder
@onready var health := $Health as Health
@onready var animator := $Body/AnimationPlayer as AnimationPlayer
@onready var ui = $CanvasLayer

var current_stand = null
var sugar_distance = StatFloat.new("player", "sugar_range", 400.0)
var health_stat := StatInt.new("player", "base_health", 100, "health_stat_increase_scalar")
var speed := StatFloat.new("player", "base_speed", 1000.0, "speed_stat_increase_scalar")
var weapon_speed := StatFloat.new("player", "weapon_speed", 0.0, "weapon_speed_stat_increase_scalar")
var damage_multiplier := StatFloat.new("player", "damage_multiplier", 1.0)
var items: Array[Item] = []
var damage_pipeline: Array[Callable] = []

func pickup_item(item: Item):
	items.push_back(item)
	
	if item is ItemWeapon:
		weapon_holder.pickup_weapon(item)

func add_damage(pipeline: Callable):
	damage_pipeline.push_back(pipeline)

func do_damage_pipeline(damage: DamageInfo):
	var final_damage = damage
	
	for item in damage_pipeline:
		final_damage = item.call(final_damage)
		
	return final_damage

func at_stand() -> bool:
	return current_stand != null

func _multiply_by_damage_stat(damage: DamageInfo):
	damage.damage = roundi(damage.damage * damage_multiplier.get_value())
	return damage

func _on_die():
	EventBus.game_over.emit()

	animator.play("Death")
	
	for weapon in weapon_holder.get_children():
		weapon.queue_free()

func _ready():
	Storage.player = self
	Storage.debug_panel["Damage"] = func(): return damage_multiplier.get_value()
	Storage.debug_panel["Weapon Speed"] = func(): return weapon_speed.get_value()
	
	health_stat.from_stream(
		func(val):
			health.max_health = val
			health.current_health = health.max_health
	)
	
	health.died.connect(_on_die)
	
	Storage.add_debug_action(
		KEY_9, 
		func():
			currency_container.total += 200000
			for i in Storage.item_pool.get_all():
				i.purchase(),
		"Give all items"
	)
	
	Storage.add_debug_action(KEY_0, func(): health.damage(999), "Kill self")
	
	damage_pipeline.push_back(_multiply_by_damage_stat)

func _unhandled_input(event):
	if event.is_action_pressed("restart_game") and health.is_dead():
		get_tree().change_scene_to_file("res://main.tscn")

func _process(delta):
	if health.is_dead():
		return

	_do_movement(delta)

func _do_movement(delta):
	var input = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"),
	)
	
	# if we're moving..
	if input != Vector2.ZERO:
		if animator.current_animation != "Running":
			animator.play("Running")
	else:
		if animator.current_animation != "Idle":
			animator.play("Idle")

	input = input.normalized()

	move_and_collide(input * speed.get_value() * delta)
