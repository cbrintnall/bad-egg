extends Node2D

var length = StatFloat.new("freeze", "time_seconds", 1.0)
var last_mode
var parent
func _ready():
#	parent = get_parent()
#	if parent is CharacterBody2D:
#		var my_mode = process_mode
#		parent.process_mode = Node.PROCESS_MODE_DISABLED
#		for child in parent.get_children():
#			Utils.set_mode(parent, Node.PROCESS_MODE_ALWAYS)
#
#	else:
#		printerr("Frozen failed, no CharacterBody2D")
#
	await get_tree().create_timer(length.get_value()).timeout
	
	queue_free()

func _process(delta):
	get_parent().velocity = Vector2.ZERO

func _exit_tree():
	parent.process_mode = last_mode
