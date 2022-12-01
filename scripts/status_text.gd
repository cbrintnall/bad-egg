extends Label

const max_x := 50.0
const max_y := 30.0
const speed := .5

func _ready():
	var tween = get_tree().create_tween()
	
	tween.tween_property(
		self,
		"global_position",
		global_position+Vector2(randf_range(-max_x, max_x),randf_range(-max_y, max_y)),
		speed
	)
	
	tween.tween_property(
		self,
		"modulate",
		Color.TRANSPARENT,
		.2
	)
	
	tween.tween_callback(queue_free)
