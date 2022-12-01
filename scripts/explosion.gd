extends Node2D

@onready var collision = $Area2D/CollisionShape2D

var size := StatFloat.new("player", "explosive_size", 50.0)
var damage := StatFloat.new("player", "explosive_damage", 1.0)

const time := 0.75

func _ready():
	scale = Vector2(.1,.1)*size.get_value()
	
	get_tree().create_tween().tween_property(
		self,
		"scale",
		Vector2.ZERO,
		time
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	$Area2D.area_entered.connect(
		func(area):
			if area.has_method("damage"):
				area.damage(damage.get_value())
	)
