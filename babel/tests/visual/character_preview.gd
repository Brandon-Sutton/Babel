extends Node2D
## PIPE-003: shows an imported character at in-game scale on greybox floor, playing one
## animation through its AnimationLibrary the way the player scene will: Sprite2D with
## hframes/vframes from the layout JSON, origin at the feet pivot, plus a mirrored copy
## (flip_h) to check facing left keeps the feet in place. Logs "VISUAL PASS" when the
## AnimationPlayer has stepped through every frame. Run --import first (the sheet is a
## texture), then capture it with tools/capture.sh.

const Greybox := preload("res://tools/builders/build_greybox_tileset.gd")
const TILE_SET: TileSet = preload("res://assets/tilesets/greybox/greybox_tileset.tres")
const FLOOR_ROW: int = 20

@export var sprite_dir: String = "res://assets/sprites/player/hero"
@export var slug: String = "hero"
@export var animation_name: StringName = &"idle"

var _seen: Dictionary[Vector2i, bool] = {}
var _expected_frames: int = 0
var _elapsed: float = 0.0
var _reported: bool = false
var _sprite: Sprite2D


func _ready() -> void:
	var floor_layer: TileMapLayer = TileMapLayer.new()
	floor_layer.tile_set = TILE_SET
	add_child(floor_layer)
	for x: int in 40:
		for y: int in range(FLOOR_ROW, 23):
			floor_layer.set_cell(Vector2i(x, y), 0, Greybox.SOLID)

	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(sprite_dir.path_join(slug + ".json")))
	_expected_frames = int(layout["animations"][String(animation_name)]["frames"])
	_sprite = _spawn(layout, Vector2(280, FLOOR_ROW * 16), false)
	_spawn(layout, Vector2(360, FLOOR_ROW * 16), true)


func _spawn(layout: Dictionary, at: Vector2, facing_left: bool) -> Sprite2D:
	var actor: Node2D = Node2D.new()
	actor.position = at
	add_child(actor)
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = load(sprite_dir.path_join(slug + ".png"))
	sprite.centered = false
	sprite.hframes = int(layout["columns"])
	sprite.vframes = int(layout["rows"])
	var pivot: Array = layout["pivot"]
	sprite.offset = -Vector2(float(pivot[0]), float(pivot[1]))
	sprite.flip_h = facing_left
	actor.add_child(sprite)
	var player: AnimationPlayer = AnimationPlayer.new()
	actor.add_child(player)
	player.add_animation_library(&"", load(sprite_dir.path_join(slug + "_anims.tres")))
	player.play(animation_name)
	return sprite


func _process(delta: float) -> void:
	_seen[_sprite.frame_coords] = true
	_elapsed += delta
	if not _reported and _elapsed >= 1.5:
		_reported = true
		var result: String = "PASS" if _seen.size() == _expected_frames else "FAIL"
		print("VISUAL %s %s/%s: %d of %d frames shown" % [result, slug, animation_name, _seen.size(), _expected_frames])
