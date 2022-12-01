@tool
extends Area2D

signal purchased

@export var cost_key: String
@onready var cost = Storage.game_settings.get_value("costs", cost_key, 0)
@onready var player = $AudioStreamPlayer2D

func _unhandled_input(event):
	if not Engine.is_editor_hint():
		if len(get_overlapping_areas()) > 0 and PlayerUtilities.can_afford(Storage.player, cost) and event.is_action_pressed("purchase"):
			Storage.player.currency_container.total -= cost
			purchased.emit()
			player.play()
