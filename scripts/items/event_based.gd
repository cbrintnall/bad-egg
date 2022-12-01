@tool

extends Item
class_name EventBasedItem

enum Source {
	SPAWN,
	PLAYER,
	ARG1,
	ARG2
}

var chosen_signal: String:
	set(val): chosen_signal = val
	get: return chosen_signal 

@export var chosen_source := Source.PLAYER
@export var chosen_node: Script
@export var chosen_scene: PackedScene
@export var starting_chance := 1.0
@export var on_pickup := false
@export_category("Flags")
@export var sets_flag := Utils.Flag.NULL

var apply_chance: StatFloat
var loaded_node

func purchase():
	super.purchase()

	if on_pickup:
		_on_event(null, null)
	else:
		EventBus.get(chosen_signal).connect(_on_event)

func load_stats():
	super.load_stats()
	
	apply_chance = StatFloat.new(exported_name, "apply_chance", starting_chance)

func _on_event(arg1 = null, arg2 = null):
	if not Engine.is_editor_hint():
		if randf() > apply_chance.get_value():
			return
		
		var source
		
		match chosen_source:
			Source.SPAWN:
				source = Storage.spawner
			Source.PLAYER:
				source = Storage.player
			Source.ARG1:
				source = arg1
			Source.ARG2:
				source = arg2
		
		if chosen_scene:
			var scene = chosen_scene.instantiate()
			if "position" in scene:
				scene.position = Vector2.ZERO
			source.add_child(scene)
		
		if chosen_node:
			var node = chosen_node.new()
			if "position" in node:
				node.position = Vector2.ZERO
			source.add_child(node)

		if sets_flag:
			Storage.change_flag(sets_flag, true)

func _get_from_source(source: Source) -> Node:
	match source:
		Source.PLAYER:
			return Storage.player
	return null

func _get_property_list():
	var properties = []
	var signals = ",".join(EventBus.get_signal_list().map(func(sig): return sig["name"]))
	properties.append({
		"name": "chosen_signal",
		"type": TYPE_STRING,
		"property_usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": signals,
	})

	return properties
