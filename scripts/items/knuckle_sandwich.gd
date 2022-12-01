extends Node

const INCREASE_AMOUNT = .2

func _ready():
	Storage.player.add_damage(
		func(dmg: DamageInfo):
			if dmg.weapon_dealing.get_meta("weapon_type", "") == "melee":
				dmg.damage = roundi(dmg.damage + (dmg.weapon_dealing.base_damage.base_value * INCREASE_AMOUNT))
			return dmg
	)
