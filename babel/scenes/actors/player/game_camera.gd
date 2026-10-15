class_name GameCamera
extends Camera2D
## The player's camera with screen shake (CBT-005). Shake moves the camera offset by
## whole pixels, so the picture stays pixel-perfect, and is scaled by the
## accessibility setting "accessibility/screen_shake" (0 turns it off).

var _strength: float = 0.0
var _frames_left: int = 0
var _total_frames: int = 1


## Shakes the active GameCamera by up to [param pixels] for [param frames] frames.
## Stronger shakes override weaker ones.
static func shake(tree: SceneTree, pixels: float, frames: int) -> void:
	var camera: GameCamera = tree.root.get_viewport().get_camera_2d() as GameCamera
	if camera != null:
		camera.add_shake(pixels, frames)


func add_shake(pixels: float, frames: int) -> void:
	var scale_setting: float = float(Settings.get_value("accessibility", "screen_shake", 1.0))
	var scaled: float = pixels * clampf(scale_setting, 0.0, 1.0)
	if scaled <= 0.0 or scaled < _current_strength():
		return
	_strength = scaled
	_frames_left = frames
	_total_frames = maxi(1, frames)


func _physics_process(_delta: float) -> void:
	if _frames_left <= 0:
		offset = Vector2.ZERO
		return
	_frames_left -= 1
	var amount: int = roundi(_current_strength())
	offset = Vector2(randi_range(-amount, amount), randi_range(-amount, amount))


func _current_strength() -> float:
	return _strength * float(_frames_left) / _total_frames if _frames_left > 0 else 0.0
