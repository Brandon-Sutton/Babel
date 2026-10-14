class_name HitStop
## Freezes the game for a few frames when a hit lands, for impact (CBT-005). Uses
## Engine.time_scale; a real-time timer restores it. Overlapping calls extend the stop.

static var _until_msec: int = 0


## Freezes gameplay for [param frames] frames (at 60 Hz).
static func trigger(tree: SceneTree, frames: int) -> void:
	if frames <= 0 or tree == null:
		return
	var until: int = Time.get_ticks_msec() + roundi(frames * 1000.0 / 60.0)
	if until <= _until_msec:
		return
	_until_msec = until
	Engine.time_scale = 0.0
	var timer: SceneTreeTimer = tree.create_timer(frames / 60.0, true, false, true)
	timer.timeout.connect(_release.bind(until))


static func _release(token: int) -> void:
	if token == _until_msec:
		Engine.time_scale = 1.0
