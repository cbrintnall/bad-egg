extends Area2D

var enemy_bounds := Vector2.ZERO

var targets := {}

func _ready():
	connect("area_entered", _on_entered)
	connect("area_exited", _on_exit)
	
func _process(delta):
	for target in targets:
		_update_target_info(target)
	
func _update_bounds():
	for target in targets:
		pass
	
func _on_exit(area):
	targets.erase(area)

func _on_entered(area):
	_update_target_info(area)
	
func _update_target_info(target: Area2D):
	if not targets.has(target):
		targets[target] = {}

	targets[target]["distance"] = global_position.distance_squared_to(target.global_position)
	targets[target]["dot"] = global_position.dot(Vector2.UP)
