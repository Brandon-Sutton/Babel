class_name SlashFX
extends Node2D
## Procedural slash shapes (VFX-011) where the art has none yet: the swing arc of a
## weapon, a long arc of any reach (Lion's Cleave), or a full spinning ring (Reaping
## Whirl). Pixel-crisp: no antialiasing.

var _frames_left: int = 0
var _total: int = 1
var _reach: float = 46.0
var _facing: int = 1
var _low: bool = false
var _color: Color = Color.WHITE
var _ring: bool = false


## Shows the arc for [param weapon]'s active frames.
func play(weapon: WeaponData, facing: int, low: bool) -> void:
	play_arc(weapon.reach, weapon.slash_color, weapon.active_frames, facing, low)


## Shows an arc of [param reach] px in [param color] for [param frames].
func play_arc(reach: float, color: Color, frames: int, facing: int, low: bool) -> void:
	_ring = false
	_total = maxi(1, frames)
	_frames_left = _total
	_reach = reach
	_facing = facing
	_low = low
	_color = color
	queue_redraw()


## Shows a full ring of [param radius] px spinning around Elam for [param frames].
func play_ring(radius: float, color: Color, frames: int) -> void:
	play_arc(radius, color, frames, 1, false)
	_ring = true


func _physics_process(_delta: float) -> void:
	if _frames_left > 0:
		_frames_left -= 1
		queue_redraw()


func _draw() -> void:
	if _frames_left <= 0:
		return
	var progress: float = 1.0 - float(_frames_left - 1) / _total
	var points: PackedVector2Array = []
	if _ring:
		var centre: Vector2 = Vector2(0.0, -44.0)
		var start: float = progress * TAU * 2.0
		for i: int in 17:
			var angle: float = start + lerpf(0.0, TAU * 0.8, i / 16.0)
			points.append((centre + Vector2(cos(angle), sin(angle) * 0.6) * _reach).round())
	else:
		var centre: Vector2 = Vector2(_facing * 6.0, -24.0 if _low else -52.0)
		var radius: float = _reach + 8.0
		var end_angle: float = lerpf(-1.1, 0.9, minf(1.0, progress * 1.4))
		for i: int in 13:
			var angle: float = lerpf(-1.1, end_angle, i / 12.0)
			points.append((centre + Vector2(cos(angle) * _facing, sin(angle)) * radius).round())
	draw_polyline(points, Color(_color, 0.55), 5.0)
	draw_polyline(points, _color, 2.0)
