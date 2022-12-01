extends Item
class_name CleanSlate

func purchase():
	super.purchase()
	Storage.player.ui.stat_upgrades.refund()
