class_name SeveredPiece
extends Node2D
## A severed boss part falling away (BOSS-030): the part's own sprite flies off with a
## spray of blood, lands, rests a while and fades. It never rotates (the grid rule), it
## only tumbles in place by flipping.

const LIFETIME_FRAMES: int = 300
const FADE_FRAMES: int = 40
const GRAVITY: float = 900.0
const DROPS: int = 14

var texture: Texture2D
## The texture pixel at the node's origin.
var pivot: Vector2 = Vector2.ZERO
var flip: bool = false
var blood: Color = Color("8a1428")
## Global y where the piece's origin comes to rest (its art then sits on the floor).
var rest_y: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var _frame: int = 0
## Where it was torn off (global): the blood sprays from here, not from the falling piece.
var _origin: Vector2 = Vector2.ZERO
var _drops: PackedVector2Array = []
var _drop_velocities: PackedVector2Array = []


## Throws the art [param part_texture] off at [param at] (global position of its pivot),
## to land on the floor at [param floor_y].
static func spawn(tree: SceneTree, part_texture: Texture2D, at: Vector2, part_pivot: Vector2, flipped: bool,
		floor_y: float, blood_color: Color, direction: float) -> SeveredPiece:
	var piece: SeveredPiece = SeveredPiece.new()
	piece.texture = part_texture
	piece.pivot = part_pivot
	piece.flip = flipped
	piece.blood = blood_color
	piece.z_index = 15
	piece.rest_y = floor_y - (part_texture.get_height() - part_pivot.y)
	piece.velocity = Vector2(direction * randf_range(60.0, 140.0), randf_range(-260.0, -160.0))
	for i: int in DROPS:
		piece._drops.append(Vector2.ZERO)
		piece._drop_velocities.append(Vector2(randf_range(-160.0, 160.0), randf_range(-280.0, -40.0)))
	var parent: Node = tree.current_scene if tree.current_scene != null else tree.root
	parent.add_child(piece)
	piece.global_position = at.round()
	piece._origin = piece.global_position
	piece.reset_physics_interpolation()
	return piece


func _physics_process(delta: float) -> void:
	_frame += 1
	if global_position.y < rest_y or velocity.y < 0.0:
		velocity.y += GRAVITY * delta
		global_position += velocity * delta
		if global_position.y >= rest_y and velocity.y > 0.0:
			global_position.y = rest_y
			# One small bounce, then it stays down.
			velocity = Vector2(velocity.x * 0.4, -velocity.y * 0.25) if absf(velocity.y) > 120.0 else Vector2.ZERO
	for i: int in _drops.size():
		_drop_velocities[i] = _drop_velocities[i] + Vector2(0.0, GRAVITY * delta)
		_drops[i] = _drops[i] + _drop_velocities[i] * delta
	if _frame >= LIFETIME_FRAMES:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var alpha: float = clampf(float(LIFETIME_FRAMES - _frame) / FADE_FRAMES, 0.0, 1.0)
	# Blood leaves from where the part was torn, so it is drawn from the spawn point.
	if _frame < 60:
		for i: int in _drops.size():
			draw_rect(Rect2((_origin + _drops[i] - global_position).round(), Vector2(2, 2)), Color(blood, 1.0 - _frame / 60.0))
	if texture == null:
		return
	if flip:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1, 1))
	draw_texture(texture, -pivot, Color(1, 1, 1, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
