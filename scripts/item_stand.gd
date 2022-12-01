extends Node2D

const amount_per_reroll = 70.0

@export var item: Item:
	set(val):
		item = val
		cost_label.text = str(item.cost.get_value())
		real_name_label.text = "\"%s\"" % str(item.name)
		sprite.texture = item.texture
		description_label.key = "%s_description" % item.exported_name
	get:
		return item

@onready var area = $Stand/Area2D
@onready var text_base = $Stand/Area2D/PanelContainer
@onready var reroll_label = $Stand/Area2D/PanelContainer/VBoxContainer/HBoxContainer/reroll
@onready var cost_label = $Stand/Area2D/PanelContainer/VBoxContainer/HBoxContainer/cost
@onready var name_label = $Stand/Area2D/PanelContainer/VBoxContainer/Label
@onready var sugar_texture_rect = $Stand/Area2D/PanelContainer/VBoxContainer/HBoxContainer/TextureRect
@onready var real_name_label = $Stand/Area2D/PanelContainer/VBoxContainer/Name
@onready var sprite = $Stand/Sprite2D
@onready var reset_player = $Reroll
@onready var description_label = $Stand/Area2D/PanelContainer/VBoxContainer/Description

var item_grabber: Callable:
	set(val):
		item_grabber = val
		item = val.call()
	get:
		return item_grabber
	
var purchased = false
var reroll_cost = amount_per_reroll:
	set(val):
		reroll_cost = val
		reroll_label.text = str(val)
	get:
		return reroll_cost

func _ready():
	add_to_group("item_stand")
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_left)
	_on_area_left(null)
	reroll_cost = amount_per_reroll
	EventBus.item_stand_spawned.emit(self)

func reset_item():
	item = item_grabber.call()
	reset_player.play()
	reroll_cost += amount_per_reroll

func _has_enough_cash():
	return Storage.player.currency_container.total >= item.cost.get_value()

func _can_buy():
	return _has_enough_cash() and not purchased and text_base.visible and item.can_purchase()

func _on_area_entered(area):
	if purchased or area.has_method("at_stand") and area.at_stand():
		return

	if "current_stand" in area:
		area.current_stand = self
	
	text_base.visible = true
	
func _on_area_left(area):
	if area and "current_stand" in area:
		area.current_stand = null

	text_base.visible = false

func _can_reroll():
	return PlayerUtilities.can_afford(Storage.player, reroll_cost) and text_base.visible and not purchased

func _process(delta):
	if text_base.visible:
		cost_label.self_modulate = Color.WHITE if _has_enough_cash() else Color.DARK_RED
		reroll_label.self_modulate = Color.WHITE if _can_reroll() else Color.DARK_RED

func _unhandled_input(event):
	if _can_buy() and event.is_action_pressed("purchase"):
		purchased = true
		item.purchase()
		EventBus.item_purchased.emit(item, self)
		_on_area_left(null)
		visible = false
		var purchase_player = $Purchase
		purchase_player.play()
		await purchase_player.finished 
		queue_free()
		
	if _can_reroll() and event.is_action_pressed("reroll"):
		reset_item()
