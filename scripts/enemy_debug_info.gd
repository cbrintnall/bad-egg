extends Label

func _process(delta):
	visible = Storage.debug
	if visible:
		var final_string = ""
		for item in Storage.enemy_debug:
			final_string += "{0}: {1}\n".format([item, Storage.enemy_debug[item].call(get_parent())])
		text = final_string
		
