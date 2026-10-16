class_name HitSpark
extends Node2D
## A short pixel starburst where a hit lands (VFX-012): a bright core and rays that
## shoot out and shrink. Drawn without antialiasing so it stays crisp.

const LIFETIME_FRAMES: int = 10

var color: Color = Color("fbe69b")
var size: float = 14.0
var _frame: int = 0
var _angles: PackedFloat32Array = []


## Adds a spark at [param at] (global position) in the current scene.
static func spawn(tree: SceneTree, at: Vector2, tint: Color = Color("fbe69b"), big: bool = false) -> void:
	var spark: HitSpark = HitSpark.new()
	spark.color = tint
	spark.size = 20.0 if big else 14.0
	spark.z_index = 55
	(tree.current_scene if tree.current_scene != null else tree.root).add_child(spark)
	spark.global_position = at.round()
	# Without this the first frame is interpolated from the origin.
	spark.reset_physics_interpolation()


func _ready() -> void:
	var turn: float = randf() * TAU
	for i: int in 6:
		_angles.append(turn + i * TAU / 6.0 + randf_range(-0.25, 0.25))


func _physics_process(_delta: float) -> void:
	_frame += 1
	if _frame >= LIFETIME_FRAMES:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var t: float = float(_frame) / LIFETIME_FRAMES
	var core: float = roundf(lerpf(5.0, 1.0, t))
	draw_rect(Rect2(Vector2(-core, -core) / 2.0, Vector2(core, core)), Color.WHITE)
	var outer: float = size * minf(1.0, t * 2.5)
	var inner: float = size * maxf(0.0, t * 1.6 - 0.4)
	for angle: float in _angles:
		var direction: Vector2 = Vector2.from_angle(angle)
		draw_line((direction * inner).round(), (direction * outer).round(), color, 1.0)
	if t < 0.3:
		draw_rect(Rect2(-1, -1, 2, 2), color)
