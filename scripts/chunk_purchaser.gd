extends Sprite2D

@export var chunk_to_purchase: Vector2i

@onready var purchasable = $Purchasable

func _ready():
	add_to_group("chunk_sign")
	
	EventBus.round_started.connect(func(count): queue_free())

	purchasable.purchased.connect(
		func():
			if chunk_to_purchase in Storage.map_generator.chunks.keys():
				printerr("Chunk purchaser was pointed at chunk that already exists!")
				queue_free()
				return
			else:
				Storage.map_generator.generate_chunk(chunk_to_purchase)
				Storage.per_round_stats.signs_bought+=1
				for sign in get_tree().get_nodes_in_group("chunk_sign"):
					if sign != self and sign.chunk_to_purchase == chunk_to_purchase:
						sign.queue_free()
				queue_free()
	)
