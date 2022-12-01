extends Item
class_name Nutshell

@export var reduction_amount := 1

func purchase():
	super.purchase()
	
	Storage.player.health.add_to_pipeline(
		func(val):
			return val - reduction_amount
	)
