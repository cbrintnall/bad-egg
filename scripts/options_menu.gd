extends Control

@onready var fullscreen_toggle = $Container/PanelContainer/Video/Fullscreen/CheckBox as CheckBox

var fullscreen_setting = Setting.new("video", "fullscreen", true)

func _ready():
	visible = false

	fullscreen_toggle.toggle_mode = true
	fullscreen_toggle.toggled.connect(
		func(val):
			fullscreen_setting.value = val
			DisplayServer.window_set_mode(_fullscreen_bool_to_mode(fullscreen_setting.value))
	)
	fullscreen_toggle.button_pressed = fullscreen_setting.value

func _fullscreen_bool_to_mode(val: bool) -> int:
	return DisplayServer.WINDOW_MODE_FULLSCREEN if val else DisplayServer.WINDOW_MODE_WINDOWED

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = false
