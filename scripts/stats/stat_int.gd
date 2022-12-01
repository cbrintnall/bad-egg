extends StatFloat
class_name StatInt

func get_value() -> float:
	return roundf(super.get_value())

func to_display() -> String:
	return "%d" % get_value()
