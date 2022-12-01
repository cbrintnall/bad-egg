extends Node
class_name PlayerUtilities

static func can_afford(player, amount: int) -> bool:
	return player.currency_container.total >= amount
