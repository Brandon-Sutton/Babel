extends RefCounted
## Visual tests press actions from script, and when the window loses focus Godot releases
## every held action. A fresh capture window usually loses focus once, a second or two
## after it opens, when the window that was active before (an editor) takes it back.
## Await settle() before the first scripted input: it returns a few frames after that
## focus loss, or after MAX_FRAMES without one.
##   const WindowSettle := preload("res://tests/visual/window_settle.gd")
##   await WindowSettle.settle(self)

const MAX_FRAMES: int = 150
const AFTER_FRAMES: int = 5


static func settle(node: Node) -> void:
	var window: Window = node.get_window()
	var lost: Array[bool] = [false]
	var on_lost: Callable = func() -> void: lost[0] = true
	window.focus_exited.connect(on_lost)
	for i: int in MAX_FRAMES:
		await node.get_tree().physics_frame
		if lost[0]:
			break
	window.focus_exited.disconnect(on_lost)
	for i: int in AFTER_FRAMES:
		await node.get_tree().physics_frame
