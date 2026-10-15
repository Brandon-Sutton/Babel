@tool
class_name SecretArea
extends Node2D
## A hidden room off the camera and the map (WLD-006), as in Symphony of the Night. Build
## it outside the room's camera bounds, behind a breakable wall or floor (BreakableTiles):
## the room's limits keep it out of sight until Elam walks or falls into [member area].
## Then the camera pans to [member view], and back to the room's bounds when he leaves.
## The first entry sets the flag "<room_id>/secret/<node name>" and emits
## Events.secret_found, which the map uses to keep it hidden until found (MAP-009).
## The rectangles show in the editor, and in game with the debug overlay (F1).

## The hidden room, in this node's coordinates. Elam is inside when his feet are.
@export var area: Rect2 = Rect2(0, 0, 160, 160):
	set(value):
		area = value
		queue_redraw()
## What the camera may show while he is inside, in this node's coordinates, at least one
## screen in size. Left empty, it is [member area] grown to one screen around its centre.
@export var view: Rect2:
	set(value):
		view = value
		queue_redraw()
## Seconds the camera takes to pan in or out.
@export var pan_seconds: float = 0.35

const AREA_HINT: Color = Color(0.4, 0.9, 1.0, 0.8)
const VIEW_HINT: Color = Color(0.4, 0.9, 1.0, 0.35)

## True once Elam has been inside (saved as [method flag]).
var is_found: bool = false
var _inside: bool = false
var _tween: Tween
var _hints_drawn: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	add_to_group(&"secret_area")
	is_found = Game.is_flag(flag())


## The world flag set when the area is first entered.
func flag() -> StringName:
	return WorldKeys.key(self, "secret/" + String(name))


## [member area] in global coordinates.
func global_area() -> Rect2:
	return Rect2(to_global(area.position), area.size)


## The camera limits while Elam is inside, in global coordinates.
func global_view() -> Rect2:
	if view.has_area():
		return Rect2(to_global(view.position), view.size)
	var screen: Vector2 = get_viewport_rect().size
	var rect: Rect2 = global_area()
	var size: Vector2 = rect.size.max(screen)
	return Rect2(rect.get_center() - size / 2.0, size)


## True while Elam is inside.
func is_player_inside() -> bool:
	return _inside


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if BreakableTiles.show_hints != _hints_drawn:
		queue_redraw()
	var player: Player = get_tree().get_first_node_in_group(&"player") as Player
	if player == null:
		return
	var inside: bool = global_area().has_point(player.global_position + Vector2(0, -2))
	if inside == _inside:
		return
	_inside = inside
	if inside:
		if not is_found:
			is_found = true
			Game.set_flag(flag())
			Events.secret_found.emit(flag())
		_pan(player.camera, global_view())
	else:
		var bounds: Rect2 = _room_bounds()
		if bounds.has_area():
			_pan(player.camera, bounds)


## The camera bounds of the room this area belongs to, in global coordinates.
func _room_bounds() -> Rect2:
	var room: Node = get_parent()
	while room != null and not room.is_in_group(&"room"):
		room = room.get_parent()
	if room == null or not (room.get(&"bounds") is Rect2):
		return Rect2()
	var bounds: Rect2 = room.get(&"bounds")
	if room is Node2D:
		bounds.position = (room as Node2D).to_global(bounds.position)
	return bounds


## Moves the camera's limits from where they are to [param target] over pan_seconds.
func _pan(camera: Camera2D, target: Rect2) -> void:
	if _tween != null:
		_tween.kill()
	var start: Rect2 = Rect2(camera.limit_left, camera.limit_top, camera.limit_right - camera.limit_left,
			camera.limit_bottom - camera.limit_top)
	_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_method(_set_limits.bind(camera, start, target), 0.0, 1.0, pan_seconds)


func _set_limits(t: float, camera: Camera2D, from: Rect2, to: Rect2) -> void:
	camera.limit_left = roundi(lerpf(from.position.x, to.position.x, t))
	camera.limit_top = roundi(lerpf(from.position.y, to.position.y, t))
	camera.limit_right = roundi(lerpf(from.end.x, to.end.x, t))
	camera.limit_bottom = roundi(lerpf(from.end.y, to.end.y, t))


func _draw() -> void:
	_hints_drawn = BreakableTiles.show_hints
	if not Engine.is_editor_hint() and not BreakableTiles.show_hints:
		return
	draw_rect(area, AREA_HINT, false, 1.0)
	if view.has_area():
		draw_rect(view, VIEW_HINT, false, 1.0)
