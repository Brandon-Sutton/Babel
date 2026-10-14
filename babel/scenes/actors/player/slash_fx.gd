class_name SlashFX
extends Node2D
## Placeholder sword arc drawn during a swing's active frames, until weapon sprites
## exist (VFX-011). Pixel-crisp: no antialiasing.

var _frames_left: int = 0
var _total: int = 1
var _reach: float = 46.0
var _facing: int = 1
var _low: bool = false
var _color: Color = Color.WHITE


## Shows the arc for [param weapon]'s active frames.
func play(weapon: WeaponData, facing: int, low: bool) -> void:
	_total = maxi(1, weapon.active_frames)
	_frames_left = _total
	_reach = weapon.reach
	_facing = facing
	_low = low
	_color = weapon.slash_color
	queue_redraw()


func _physics_process(_delta: float) -> void:
	if _frames_left > 0:
		_frames_left -= 1
		queue_redraw()


func _draw() -> void:
	if _frames_left <= 0:
		return
	var progress: float = 1.0 - float(_frames_left - 1) / _total
	var centre: Vector2 = Vector2(_facing * 6.0, -24.0 if _low else -52.0)
	var radius: float = _reach + 8.0
	var points: PackedVector2Array = []
	var start_angle: float = -1.1
	var end_angle: float = lerpf(-1.1, 0.9, minf(1.0, progress * 1.4))
	for i: int in 13:
		var angle: float = lerpf(start_angle, end_angle, i / 12.0)
		points.append((centre + Vector2(cos(angle) * _facing, sin(angle)) * radius).round())
	draw_polyline(points, Color(_color, 0.55), 5.0)
	draw_polyline(points, _color, 2.0)
