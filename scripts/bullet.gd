extends Sprite2D

signal reached_target(target)

var target: Node2D

@export var speed := 30.0

func _ready():
	target.connect("tree_exiting", queue_free)

func _process(delta):
	if not is_instance_valid(target) or not target.is_inside_tree():
		queue_free()
		return
 
	var dir_to = global_position.direction_to(target.global_position)
	global_position += dir_to * speed
	var dir_after = global_position.direction_to(target.global_position)
	var dot_after = dir_to.dot(dir_after)
	
	if sign(dot_after) < 0.0:
		reached_target.emit(target)
		queue_free()
