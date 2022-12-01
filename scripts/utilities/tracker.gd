extends RefCounted
class_name Tracker

var _db := {}

func add(tracked):
	_db[tracked] = true
	
func reset():
	_db = {}
	
func has(tracked):
	return _db.get(tracked, null) != null
