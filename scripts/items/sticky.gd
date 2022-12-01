extends Item
class_name Sticky

func _get_name():
	return "Sticky"

func purchase():
	super.purchase()
	
	(Storage.player.sugar_distance as StatFloat).set_value(INF)
