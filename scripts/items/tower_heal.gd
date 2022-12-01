extends TowerItem
class_name TowerHeal

var amount: StatInt

func _post_init():
	amount = StatInt.new(
		_get_name(),
		"heal_amount",
		1.0
	)

func _apply_effect(item, stand):
	Storage.player.health.heal(amount.get_value())
