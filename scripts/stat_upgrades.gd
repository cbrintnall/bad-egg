extends VBoxContainer

signal confirmed

const points_per_round = 5

@onready var confirmed_btn = $Done
@onready var available_points_label = $Label

var available_points := 0
var spent_points := 0

func refund():
	available_points = spent_points 
	spent_points = 0
	for child in get_children():
		if child.has_method("reset"):
			child.reset()

func _ready():
	confirmed_btn.button_up.connect(
		func():
			for child in get_children():
				if child.has_method("confirmed"):
					child.confirmed()
					
			visible = false
			spent_points += points_per_round
			EventBus.confirmed_points.emit()
	)

	EventBus.round_end.connect(
		func():
			available_points += points_per_round
			visible = true
	)
	
	for child in get_children():
		if "stat_parent" in child:
			child.stat_parent = self
			
	visible = false

func _process(delta):
	available_points_label.text = "%d/%d" % [available_points,points_per_round]
	confirmed_btn.disabled = available_points != 0
