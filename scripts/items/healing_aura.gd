extends Node2D

@onready var healing_timer = $HealingTimer as Timer
@onready var tick_timer = $Timer as Timer
@onready var particles = $Leaves as GPUParticles2D
@onready var shape = $Area2D/CollisionShape2D as CollisionShape2D
@export var main_color: Color
@export var pulse_color: Color

var size := StatFloat.new("player", "aura_size", 50.0)
var tick_time := StatFloat.new("player", "healing_aura_tick_time", 3.0)
var heal := StatInt.new("player", "healing", 1)
var enabled := true:
	set(val):
		tick_timer.paused = not val
		enabled = val
	get:
		return enabled
var tracker := Tracker.new()

func _ready():
	main_color.a = .1
	var area = $Area2D as Area2D
	
	size.from_stream(
		func(val):
			shape.shape.radius = val
			particles.process_material.emission_sphere_radius = val
	)
	
	tick_time.from_stream(
		func(val):
			tick_timer.wait_time = val
			healing_timer.wait_time = val * 0.3
	)
	
	tick_timer.timeout.connect(
		func():
			tracker.reset()
			particles.emitting = true
			healing_timer.start()
			for other in area.get_overlapping_areas():
				if other.has_method("heal"):
					other.heal(heal.get_value())
	)
	
	area.area_entered.connect(
		func(area):
			if tracker.has(area) or not enabled or healing_timer.is_stopped():
				return
			
			if area.has_method("heal"):
				area.heal(heal.get_value())
	)

func _process(delta):
	queue_redraw()

func _draw():
	if enabled:
		draw_circle(Vector2.ZERO, size.get_value(), main_color)
