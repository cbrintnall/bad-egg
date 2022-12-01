extends Control

@onready var options = $VBoxContainer/Options
@onready var options_menu = get_node("../Options")
@onready var main_menu_scene = load("res://scenes/mains/main_menu.tscn")

func _ready():
	get_node("VBoxContainer/End Run").button_down.connect(func(): get_tree().change_scene_to_packed(main_menu_scene))
	options.button_down.connect(func(): options_menu.visible = true)
	$VBoxContainer/Resume.button_down.connect(func(): visible = false)
	EventBus.game_over.connect(
		func():
			get_node("VBoxContainer/End Run").text = "Main Menu"
	)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and not options_menu.visible:
		visible = not visible
