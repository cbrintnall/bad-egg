extends RefCounted
class_name WeightedPool

var _data := {}
var _weight_total := 0.0

func add(data: Item):
	_data[data] = {}
	_sync_weights()

func remove(data: Item):
	_data.erase(data)
	_sync_weights()

func add_many(data: Array):
	for piece in data:
		_data[piece] = {}
	_sync_weights()

func count() -> int:
	return len(_data)
	
func get_all() -> Array[Item]:
	return _data.keys()

func get_random() -> Item:
	return _get_random(_data, _weight_total)

func _get_random(weights: Dictionary, total_sum: float) -> Item:
	var roll: float = randf_range(0.0, total_sum)
	for obj_type in weights:
		if (_data[obj_type]["acc_weight"] > roll):
			return obj_type

	return null

func _sync_weights():
	for data in _data:
		_data[data] = { "acc_weight": 0.0 }
		
	_weight_total = _init_probabilities(_data)

# Returns the total accumulated weights, which should be used when randomly picking an object from the array (http://kehomsforge.com/tutorials/single/GDWeightedRandom)
func _init_probabilities(weights: Dictionary) -> float:
	var total: float = 0.0
	for obj_type in weights:
		var weight = 1.0
		if not (obj_type is Item):
			printerr("Cannot create weight pool without item class..")
		else:
			weight = obj_type.spawn_chance.get_value()
		total += weight
		_data[obj_type]["acc_weight"] = total

	return total
