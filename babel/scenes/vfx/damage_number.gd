class_name DamageNumber
extends Node2D
## A number (or short text such as "LEVEL UP") that pops up, rises and fades, Symphony of
## the Night style (CBT-004). Spawn with [method spawn] or [method spawn_text].
## Pooling comes with CBT-008.

const LIFETIME_FRAMES: int = 45
const RISE: float = 22.0

var text: String = ""
var color: Color = Color.WHITE
var scale_px: int = 2
var lifetime_frames: int = LIFETIME_FRAMES
var _frame: int = 0
var _start: Vector2


## Shows a damage amount at [param at] (global position).
static func spawn(tree: SceneTree, at: Vector2, value: int, tint: Color, big: bool = false) -> void:
	spawn_text(tree, at, str(value), tint, 3 if big else 2)


## Shows [param message] at [param at] (global position).
static func spawn_text(tree: SceneTree, at: Vector2, message: String, tint: Color,
		pixel_scale: int = 2, frames: int = LIFETIME_FRAMES) -> void:
	var number: DamageNumber = DamageNumber.new()
	number.text = message
	number.color = tint
	number.scale_px = pixel_scale
	number.lifetime_frames = frames
	number.z_index = 60
	(tree.current_scene if tree.current_scene != null else tree.root).add_child(number)
	number.global_position = at.round()
	number.reset_physics_interpolation()
	# Set after positioning: _ready() runs inside add_child, before the position is known.
	number._start = number.position


func _physics_process(_delta: float) -> void:
	_frame += 1
	var t: float = float(_frame) / lifetime_frames
	# Fast pop up, then drift and fade.
	position = (_start + Vector2(0, -RISE * (1.0 - pow(1.0 - t, 3.0)))).round()
	modulate.a = 1.0 if t < 0.6 else 1.0 - (t - 0.6) / 0.4
	if _frame >= lifetime_frames:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var width: int = PixelFont.text_width(text, scale_px)
	PixelFont.draw_text(self, Vector2(-floori(width / 2.0), -PixelFont.GLYPH_H * scale_px), text, color,
			scale_px, Color("0b0a10"))
