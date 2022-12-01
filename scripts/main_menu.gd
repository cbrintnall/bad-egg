extends Control

@export var game_scene: PackedScene
@export var hover_sound: AudioStream
@export var click_sound: AudioStream

@onready var rain_particles = $GPUParticles2D as GPUParticles2D

func _ready():
	$VBoxContainer/Quit.button_down.connect(func(): get_tree().quit())
	$VBoxContainer/Options.button_down.connect(func(): $Options.visible = !$Options.visible)
	$VBoxContainer/Play.button_down.connect(_new_game)

	for button in Utils.get_all_children_that(self, func(child): return child is Button):
		(button as Button).mouse_entered.connect(func(): _play_sound(hover_sound))
		(button as Button).button_down.connect(func(): _play_sound(click_sound))

	EventBus.in_main_menu.emit()

func _process(delta):
	var resolution = get_viewport_rect().size
	
	rain_particles.global_position = Vector2(size.x/2, -10.0)
	(rain_particles.process_material as ParticleProcessMaterial).emission_box_extents = Vector3(size.x, size.y, 0.0)

func _new_game():
	get_tree().change_scene_to_packed(game_scene)

func _play_sound(sound: AudioStream):
	$AudioStreamPlayer.stream = sound
	$AudioStreamPlayer.play()
