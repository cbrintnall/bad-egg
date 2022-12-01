extends Item
class_name ApplyBurning

var apply_chance: StatFloat

var burning = preload("res://scenes/effects/burning.tscn")

func _init():
	super._init()
	apply_chance = StatFloat.new(name, "apply_chance", 10.0)

func _get_name():
	return "Sizzle"

func purchase():
	super.purchase()

	EventBus.enemy_damaged.connect(
		func(enemy):
			if randf() < apply_chance.get_value():
				var new_burning = burning.instantiate()
				enemy.add_child(new_burning)
	)
