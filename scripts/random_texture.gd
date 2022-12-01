extends AtlasTexture
class_name RandomTexture

@export var options: Array[Texture2D] = []

func draw_rect(canvas_item: RID, rect: Rect2, tile: bool, modulate: Color = Color(1, 1, 1, 1), transpose: bool = false):
	super.draw_rect(get_rid(), options.pick_random().region, tile, modulate, transpose)

