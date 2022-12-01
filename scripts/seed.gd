extends Area2D

var target: Node2D
var direction: Vector2
const speed = 300.0

func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	direction = global_position.direction_to(target.global_position)
	
func _physics_process(delta):
	global_position += (direction * delta * speed)
