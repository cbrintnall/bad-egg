extends Area2D

signal damaged(area: Area2D)

@export var damage := 1
@export var signal_only := false

@onready var shape := $CollisionShape2D as CollisionShape2D

var damage_decorator: Callable
var tracking = {}

var enabled:
	set(val):
		monitoring = val
	get:
		return monitoring

func reset():
	tracking = {}

func _ready():
	connect(
		"area_entered",
		func(area):
			if not (area in tracking) and area.has_method("damage"):
				_apply_damage(area)
	)

func _apply_damage(area):
	tracking[area] = true
	if not signal_only:
		area.damage(damage)
	emit_signal("damaged", area)
