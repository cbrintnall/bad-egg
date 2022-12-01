extends Item
class_name BeggarsCantBeChoosers

func purchase():
	super.purchase()
	
	Storage.map_generator.neighbor_directions.erase(Vector2i.RIGHT)
	Storage.map_generator.neighbor_directions.erase(Vector2i.LEFT)

	Storage.player.currency_container.total *= 2.0
