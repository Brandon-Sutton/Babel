class_name Rubble
extends Node2D
## Chunks of a broken tile that fly out, fall and fade (WLD-006). Each chunk is a small
## piece of the tile's own art, so the rubble always matches the wall it came from.

const LIFETIME_FRAMES: int = 45
const FADE_FRAMES: int = 12
const GRAVITY: float = 900.0
const CHUNK: int = 4

var texture: Texture2D
var _regions: Array[Rect2] = []
var _positions: PackedVector2Array = []
var _velocities: PackedVector2Array = []
var _frame: int = 0


## Throws [param count] chunks cut from [param region] of [param tile_texture] out of
## [param at] (global), at up to [param speed] px/s.
static func spawn(tree: SceneTree, at: Vector2, tile_texture: Texture2D, region: Rect2, count: int,
		speed: float) -> void:
	var rubble: Rubble = Rubble.new()
	rubble.texture = tile_texture
	rubble.z_index = 30
	var span: Vector2i = Vector2i(region.size) - Vector2i(CHUNK, CHUNK)
	for i: int in count:
		var corner: Vector2 = region.position + Vector2(randi_range(0, maxi(span.x, 0)), randi_range(0, maxi(span.y, 0)))
		rubble._regions.append(Rect2(corner, Vector2(CHUNK, CHUNK)))
		rubble._positions.append(Vector2(randf_range(-6.0, 6.0), randf_range(-6.0, 6.0)))
		rubble._velocities.append(Vector2(randf_range(-1.0, 1.0), randf_range(-1.3, -0.2)) * speed)
	var parent: Node = tree.current_scene if tree.current_scene != null else tree.root
	parent.add_child(rubble)
	rubble.global_position = at.round()
	# Without this the first frame is interpolated from the origin.
	rubble.reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	_frame += 1
	for i: int in _positions.size():
		_velocities[i] = _velocities[i] + Vector2(0.0, GRAVITY * delta)
		_positions[i] = _positions[i] + _velocities[i] * delta
	if _frame >= LIFETIME_FRAMES:
		queue_free()
	queue_redraw()


func _draw() -> void:
	if texture == null:
		return
	var alpha: float = clampf(float(LIFETIME_FRAMES - _frame) / FADE_FRAMES, 0.0, 1.0)
	var half: Vector2 = Vector2(CHUNK, CHUNK) / 2.0
	for i: int in _positions.size():
		draw_texture_rect_region(texture, Rect2((_positions[i] - half).round(), Vector2(CHUNK, CHUNK)), _regions[i],
				Color(1.0, 1.0, 1.0, alpha))
