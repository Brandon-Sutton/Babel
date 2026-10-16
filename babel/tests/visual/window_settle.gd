extends RefCounted
## Keeps the desktop out of scripted visual tests, which press actions from script:
## - isolate_input() removes the gamepad bindings for the run. Godot reads controllers
##   even when its window isn't focused, and stick noise around zero counts as releasing
##   a direction, so a connected controller dropped held actions at random.
## - settle() also waits out a focus loss. Losing focus releases every held action;
##   tools/capture.sh opens the window unfocusable (no_focus), so this returns after a few
##   frames there. A window that did get focus (a scene run by hand) usually loses it once,
##   a second or two after it opens: then settle() returns a few frames after that loss,
##   or after MAX_FRAMES.
##   const WindowSettle := preload("res://tests/visual/window_settle.gd")
##   WindowSettle.isolate_input()       # in _ready() of a test with its own frame script
##   await WindowSettle.settle(self)    # before the first input of an awaiting test

const MAX_FRAMES: int = 150
const AFTER_FRAMES: int = 5


## Removes every gamepad binding from the input map for this run (it isn't saved).
static func isolate_input() -> void:
	for action: StringName in InputMap.get_actions():
		for event: InputEvent in InputMap.action_get_events(action):
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				InputMap.action_erase_event(action, event)


static func settle(node: Node) -> void:
	isolate_input()
	var window: Window = node.get_window()
	if not window.has_focus():
		for i: int in AFTER_FRAMES:
			await node.get_tree().physics_frame
		return
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
