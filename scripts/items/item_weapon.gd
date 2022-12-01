extends Item
class_name ItemWeapon

@export var weapon_scene: PackedScene
@export var pickup_sound: AudioStream

func can_purchase() -> bool:
	return Storage.player.weapon_holder.get_child_count() < 4
