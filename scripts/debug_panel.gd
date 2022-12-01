extends CanvasLayer

@onready var debug_panel = $DebugPanel
@onready var label = $DebugPanel/VBoxContainer/Label
@onready var player_ui = $PlayerUI
@onready var round_number = $PlayerUI/MarginContainer/VBoxContainer/HBoxContainer/Round
@onready var round_timer = $PlayerUI/MarginContainer/VBoxContainer/TimeTracker/TimeLeft
@onready var stat_upgrades = $PlayerUI/StatUpgrades
@onready var start_round_label = $PlayerUI/Label

var debug_label: Label

func _ready():
	debug_label = Label.new()
	start_round_label.visible = false
	$DebugPanel/VBoxContainer.add_child(debug_label)
	
	Storage.add_debug_action(KEY_F1, func(): Storage.player.currency_container.add(99999999999), "Give currency")
	Storage.add_debug_action(KEY_F2, func(): Storage.spawner._on_round_end(), "End round")
	Storage.add_debug_action(KEY_F3, func(): stat_upgrades.available_points += 50, "Give stat points")
	Storage.add_debug_action(KEY_F4, _reroll_item_stands, "Reroll all items")
	Storage.add_debug_action(KEY_F12, _kill_all_enemies, "Kill all enemies")
	Storage.add_debug_action(KEY_F5, func(): Storage.player.health.current_health = 1, "Hurt player")

func _kill_all_enemies():
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.health.damage(999)

func _reroll_item_stands():
	for node in get_tree().get_nodes_in_group("item_stand"):
				node.reset_item()

func _update_debug():
	debug_panel.visible = Storage.debug
	if debug_panel.visible:
		var final_string = ""
		for item in Storage.debug_panel:
			if (Storage.debug_panel[item] as Callable).is_null() or not (Storage.debug_panel[item] as Callable).is_valid():
				continue
			var value = Storage.debug_panel[item].call()
			if value:
				final_string += "%s: %s\n" % [item, value]
		label.text = final_string

		var final_actions_string := "Debug actions:\n"
		for item in Storage.debug_actions:
			final_actions_string += "%s - %s\n" % [str(OS.get_keycode_string(item)), Storage.debug_actions[item]["description"]]
		debug_label.text = final_actions_string

func _update_ui():
	start_round_label.visible = not Storage.spawner.round_active
	
	if Storage.spawner.round_active:
		round_timer.text = "%.1f" % Storage.spawner.round_timer.time_left
	else:
		round_timer.text = Storage.translations.get_text("round_inactive")
		
	if Storage.spawner.round_active and Storage.spawner.round_count > 0:
		round_number.text = Storage.translations.get_text("round_number") % Storage.spawner.round_count

func _process(delta):
	_update_ui()
	_update_debug()
