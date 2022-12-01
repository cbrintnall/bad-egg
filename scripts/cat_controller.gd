extends CharacterBody2D
class_name Cat

@onready var healing = $HealingAura

func _process(delta):
	healing.enabled = Storage.flag_enabled(Utils.Flag.CAT_HEAL)
