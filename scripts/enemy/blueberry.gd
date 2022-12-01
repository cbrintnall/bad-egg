extends Enemy

@onready var damager = $TouchDamager

func _ready():
	super._ready()

	var face_animator := $AnimationPlayer as AnimationPlayer
	var timer = $Timer
	if randf() < 0.5:
		timer.timeout.connect(
			func():
				if randf() < 0.1:
					face_animator.play("Yell")
					timer.paused = true
					await face_animator.animation_finished
					face_animator.play("Idle")
					timer.paused = false
		)
	
	damager.damaged.connect(
		func(area):
			await get_tree().create_timer(2.0).timeout
			damager.reset()
	)

func _on_death(from_round_end: bool):
	if not from_round_end:
		_drop_sugar()

	$AnimationPlayer.stop()
	$AnimationPlayer2.stop()
	$Body.visible = false
	$Health.process_mode = Node.PROCESS_MODE_DISABLED
	($Timer as Timer).stop()
	$DeathPlayer.play()
	$GPUParticles2D.emitting = true
	$TouchDamager.enabled = false
	$Shadow.visible = false

	await $DeathPlayer.finished
	super._on_death(from_round_end)
