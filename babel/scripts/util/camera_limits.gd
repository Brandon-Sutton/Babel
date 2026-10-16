class_name CameraLimits
extends RefCounted
## Camera limits as rectangles, panned smoothly between a room's bounds and a smaller or
## different view: secret areas (WLD-006) and boss arenas (BOSS-000).


## The limits of [param camera] as a global rectangle.
static func current(camera: Camera2D) -> Rect2:
	return Rect2(camera.limit_left, camera.limit_top, camera.limit_right - camera.limit_left,
			camera.limit_bottom - camera.limit_top)


## Sets the limits of [param camera] to [param rect] at once.
static func apply(camera: Camera2D, rect: Rect2) -> void:
	camera.limit_left = roundi(rect.position.x)
	camera.limit_top = roundi(rect.position.y)
	camera.limit_right = roundi(rect.end.x)
	camera.limit_bottom = roundi(rect.end.y)


## Moves the limits of [param camera] from where they are to [param target] over
## [param seconds], on a tween owned by [param owner] (so it stops if the owner goes).
static func pan(owner: Node, camera: Camera2D, target: Rect2, seconds: float) -> Tween:
	var start: Rect2 = current(camera)
	var tween: Tween = owner.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_method(func(t: float) -> void:
		apply(camera, Rect2(start.position.lerp(target.position, t), start.size.lerp(target.size, t))),
		0.0, 1.0, seconds)
	return tween


## The camera bounds of the room [param node] is in, in global coordinates (empty if it
## isn't in a room with bounds).
static func room_bounds(node: Node) -> Rect2:
	var room: Node = node
	while room != null and not room.is_in_group(&"room"):
		room = room.get_parent()
	if room == null or not (room.get(&"bounds") is Rect2):
		return Rect2()
	var bounds: Rect2 = room.get(&"bounds")
	if room is Node2D:
		bounds.position = (room as Node2D).to_global(bounds.position)
	return bounds
