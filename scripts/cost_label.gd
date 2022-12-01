extends VBoxContainer

const CANT_AFFORD_COLOR = Color("#9e2081")
const CAN_AFFORD_COLOR = Color("#ffffe1")

@export_node_path var purchasable_path

@onready var label = $HBoxContainer/Label
@onready var purchase_area = get_node(purchasable_path) as Area2D

func _ready():
	label.text = str(purchase_area.cost)

func _process(delta):
	label.modulate = CAN_AFFORD_COLOR if PlayerUtilities.can_afford(Storage.player, purchase_area.cost) else CANT_AFFORD_COLOR
	visible = purchase_area.overlaps_area(Storage.player.health)
