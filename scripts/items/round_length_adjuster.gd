extends Item
class_name RoundLengthAdjuster

@export var amount := 0.0

func purchase():
	super.purchase()
	
	var adjustment_amount = (Storage.spawner.round_cap* amount)
	print("Modifying amount by %s " % str(adjustment_amount))
	Storage.spawner.round_cap += adjustment_amount
