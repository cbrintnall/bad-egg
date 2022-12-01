extends Node2D

const VU_COUNT = 16
const FREQ_MAX = 22000.0
const FREQ_MIN = 20.0
const THRESHOLD = 0.2
const SAMPLES = 50

@export var stream: AudioStreamMicrophone
@export var bus: String

@onready var bus_idx = AudioServer.get_bus_index(bus)
@onready var effect = AudioServer.get_bus_effect_instance(bus_idx, 0) as AudioEffectSpectrumAnalyzerInstance

var readings := []
var last_over := false

func _process(delta):
	var top = effect.get_magnitude_for_frequency_range(FREQ_MIN, FREQ_MAX).length()
	readings.push_front(top)
	var readings_len = len(readings)
	readings.resize(min(readings_len, SAMPLES))
	var avg = readings.reduce(func(acc, next): return acc + next, 0.0)/readings_len
	var over = avg >= THRESHOLD
	if over and not last_over:
		Storage.player.health.heal(1)
	last_over = over
