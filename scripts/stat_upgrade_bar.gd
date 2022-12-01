extends HBoxContainer
class_name StatContainer

enum PlayerStat {
	HEALTH,
	CURRENCY_DISTANCE,
	SPEED,
	WEAPON_SPEED,
	DODGE
}

enum PlayerStatAction {
	INCR,
	DECR
}

const PENDING_STATS = Color("#7e9770")
const DEFAULT_COLOR = Color.WHITE

@export var controlled_stat: PlayerStat
@export var stat_action := PlayerStatAction.INCR
@export var stat_name: String
@export var stat_preview_texture: Texture2D

@onready var amount_label = $StatName/HBoxContainer/Amount
@onready var preview_texture = $StatName/HBoxContainer/TextureRect
@onready var name_label = $StatName/HBoxContainer/Name
@onready var decrease_btn = $Minus/Button
@onready var increase_btn = $Plus/Button2

var stat_parent
var points_to_commit := 0.0
var stat

func confirmed():
	var stat = _get_stat()
	match stat_action:
		PlayerStatAction.INCR:
			stat.incr(stat.with_scalar(points_to_commit))
		PlayerStatAction.DECR:
			stat.decr(stat.with_scalar(points_to_commit))
	points_to_commit = 0.0

func reset():
	_get_stat().reset()

func _get_stat():
	match controlled_stat:
		PlayerStat.HEALTH:
			return Storage.player.health_stat
		PlayerStat.SPEED:
			return Storage.player.speed
		PlayerStat.WEAPON_SPEED:
			return Storage.player.weapon_speed
		PlayerStat.DODGE:
			return Storage.player.health.dodge

func _sync_stat():
	stat = _get_stat()

func _ready():
	name_label.text = stat_name
	preview_texture.texture = stat_preview_texture
	
	decrease_btn.button_down.connect(
		func():
			var commitment = min(_point_commit_amount(), points_to_commit)
			points_to_commit = max(points_to_commit-commitment, 0.0)
			stat_parent.available_points += commitment
	)
	
	increase_btn.button_down.connect(
		func():
			if stat_parent.available_points > 0:
				var commitment = min(_point_commit_amount(), stat_parent.available_points)
				points_to_commit = points_to_commit+commitment
				stat_parent.available_points -= commitment
	)
	
	call_deferred("_sync_stat")

func _point_commit_amount() -> int:
	var amount = 1
	if Input.is_key_pressed(KEY_SHIFT):
		amount = 5
	if Input.is_key_pressed(KEY_CTRL):
		amount = 10
	return amount

func _process(delta):
	increase_btn.disabled = stat_parent.available_points <= 0.0 or stat.at_max()
	decrease_btn.disabled = points_to_commit <= 0.0 or stat.at_min()
	amount_label.self_modulate = PENDING_STATS if points_to_commit > 0.0 else DEFAULT_COLOR
	amount_label.text = ("(%s)" % stat.to_display()) if points_to_commit == 0.0 else ("(%s + %s)" % [stat.to_display(), str(stat.with_scalar(points_to_commit))])
