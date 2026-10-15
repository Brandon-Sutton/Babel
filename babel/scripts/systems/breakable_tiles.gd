class_name BreakableTiles
extends Node2D
## Breakable walls and floors painted as tiles (WLD-006), like Symphony of the Night's
## secret walls. Add one as a child of a TileMapLayer: every cell whose tile has the
## custom data "breakable" above 0 (the hits it takes) can be broken, and touching cells
## break together as one group. The greybox TileSet has a hidden variant of the solid
## tile (alternative 1, looks the same, 3 hits) and the cracked brick (2 hits).
##
## Each hit from Elam's weapons, weapon arts or Relic Arms cracks the group and knocks
## dust off it; the last one crumbles it into rubble and saves the world flag
## "<room_id>/<layer name>@x,y" (the group's top-left cell), so it stays broken when the
## room reloads. Enemy attacks don't mask the breakable layer, so only Elam breaks walls.

## Emitted when a group crumbles, with its cells.
signal broken(cells: Array[Vector2i])

const CUSTOM_DATA: String = "breakable"
## Physics layer 12, breakable (CLAUDE.md collision table).
const BREAKABLE_LAYER: int = 1 << 11
## Hurtboxes reach this far past the tiles, so a crouching strike reaches the floor.
const HIT_MARGIN: float = 12.0
const FLASH_FRAMES: int = 6
const CRACK: Color = Color(0.04, 0.03, 0.07, 0.9)
const HINT: Color = Color(1.0, 0.85, 0.4, 0.7)

## Outlines every breakable group and secret area (debug overlay, F1).
static var show_hints: bool = false


## One set of touching breakable cells.
class Group:
	var cells: Array[Vector2i] = []
	var hits: int = 1
	var damage: int = 0
	var flag: StringName
	var hurtbox: Hurtbox
	var flash_frames: int = 0


var _layer: TileMapLayer
var _groups: Array[Group] = []
var _hints_drawn: bool = false


func _ready() -> void:
	_layer = get_parent() as TileMapLayer
	if _layer == null:
		push_error("BreakableTiles must be a child of a TileMapLayer")
		return
	# After the room has painted its tiles.
	_scan.call_deferred()


## Number of groups still standing.
func group_count() -> int:
	return _groups.size()


## Hits the group at [param cell] still takes, or 0 if nothing breakable is there.
func hits_left(cell: Vector2i) -> int:
	var group: Group = _group_at(cell)
	return group.hits - group.damage if group != null else 0


## Lands one hit on the group at [param cell] (a bomb or a scripted collapse). Returns
## whether there was a group to hit.
func strike(cell: Vector2i) -> bool:
	var group: Group = _group_at(cell)
	if group == null:
		return false
	_strike(group, _layer.to_global(_layer.map_to_local(cell)))
	return true


func _scan() -> void:
	_groups.clear()
	if _layer.tile_set == null or not _layer.tile_set.has_custom_data_layer_by_name(CUSTOM_DATA):
		return
	var hits_at: Dictionary[Vector2i, int] = {}
	for cell: Vector2i in _layer.get_used_cells():
		var data: TileData = _layer.get_cell_tile_data(cell)
		var hits: int = int(data.get_custom_data(CUSTOM_DATA)) if data != null else 0
		if hits > 0:
			hits_at[cell] = hits
	var seen: Dictionary[Vector2i, bool] = {}
	for start: Vector2i in hits_at:
		if seen.has(start):
			continue
		var group: Group = Group.new()
		var stack: Array[Vector2i] = [start]
		seen[start] = true
		while not stack.is_empty():
			var cell: Vector2i = stack.pop_back()
			group.cells.append(cell)
			group.hits = maxi(group.hits, hits_at[cell])
			for step: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var next: Vector2i = cell + step
				if hits_at.has(next) and not seen.has(next):
					seen[next] = true
					stack.append(next)
		var corner: Vector2i = group.cells[0]
		for cell: Vector2i in group.cells:
			corner = corner.min(cell)
		group.flag = WorldKeys.key(self, "%s@%d,%d" % [_layer.name, corner.x, corner.y])
		if Game.is_flag(group.flag):
			for cell: Vector2i in group.cells:
				_layer.erase_cell(cell)
			continue
		_add_hurtbox(group)
		_groups.append(group)
	queue_redraw()


func _add_hurtbox(group: Group) -> void:
	var hurtbox: Hurtbox = Hurtbox.new()
	hurtbox.name = "Breakable%d" % _groups.size()
	hurtbox.collision_layer = BREAKABLE_LAYER
	hurtbox.collision_mask = 0
	hurtbox.monitoring = false
	hurtbox.owner_node = self
	var tile: Vector2 = Vector2(_layer.tile_set.tile_size)
	for cell: Vector2i in group.cells:
		var rect: RectangleShape2D = RectangleShape2D.new()
		rect.size = tile + Vector2.ONE * HIT_MARGIN * 2.0
		var shape: CollisionShape2D = CollisionShape2D.new()
		shape.shape = rect
		shape.position = _layer.map_to_local(cell)
		hurtbox.add_child(shape)
	hurtbox.handler = _on_hit.bind(group)
	add_child(hurtbox)
	for cell: Vector2i in group.cells:
		hurtbox.terrain_rects.append(Rect2(_layer.to_global(_layer.map_to_local(cell)) - tile / 2.0, tile))
	group.hurtbox = hurtbox


func _on_hit(info: DamageInfo, group: Group) -> bool:
	if group.damage >= group.hits:
		return false
	var from: Vector2 = (info.source as Node2D).global_position if info.source is Node2D else info.position
	_strike(group, _impact_point(group, from))
	return true


func _strike(group: Group, at: Vector2) -> void:
	group.damage += 1
	group.flash_frames = FLASH_FRAMES
	_dust(group.cells[0], at, 4, 90.0)
	if group.damage >= group.hits:
		_break(group)
	else:
		HitStop.trigger(get_tree(), 2)
		GameCamera.shake(get_tree(), 1.0, 4)
	queue_redraw()


func _break(group: Group) -> void:
	for cell: Vector2i in group.cells:
		_dust(cell, _layer.to_global(_layer.map_to_local(cell)), 5, 160.0)
		_layer.erase_cell(cell)
	group.hurtbox.queue_free()
	_groups.erase(group)
	Game.set_flag(group.flag)
	GameCamera.shake(get_tree(), 3.0, 12)
	broken.emit(group.cells)


## Rubble cut from the art of the tile at [param cell], thrown out of [param at].
func _dust(cell: Vector2i, at: Vector2, count: int, speed: float) -> void:
	var source: TileSetAtlasSource = _layer.tile_set.get_source(_layer.get_cell_source_id(cell)) as TileSetAtlasSource
	if source == null:
		return
	var region: Rect2 = Rect2(source.get_tile_texture_region(_layer.get_cell_atlas_coords(cell)))
	Rubble.spawn(get_tree(), at, source.texture, region, count, speed)


## The point of the group's tiles nearest to [param from] (global).
func _impact_point(group: Group, from: Vector2) -> Vector2:
	var best: Vector2 = group.hurtbox.terrain_rects[0].get_center()
	for rect: Rect2 in group.hurtbox.terrain_rects:
		var point: Vector2 = from.clamp(rect.position, rect.end)
		if point.distance_squared_to(from) < best.distance_squared_to(from):
			best = point
	return best


func _group_at(cell: Vector2i) -> Group:
	for group: Group in _groups:
		if group.cells.has(cell):
			return group
	return null


func _physics_process(_delta: float) -> void:
	var redraw: bool = show_hints != _hints_drawn
	for group: Group in _groups:
		if group.flash_frames > 0:
			group.flash_frames -= 1
			redraw = true
	if redraw:
		queue_redraw()


func _draw() -> void:
	_hints_drawn = show_hints
	if _layer == null or _layer.tile_set == null:
		return
	var tile: Vector2 = Vector2(_layer.tile_set.tile_size)
	for group: Group in _groups:
		for cell: Vector2i in group.cells:
			var top_left: Vector2 = _layer.map_to_local(cell) - tile / 2.0
			for stage: int in group.damage:
				_draw_crack(top_left, tile, hash(cell) + stage * 7919)
			if group.flash_frames > 0:
				draw_rect(Rect2(top_left, tile), Color(1.0, 1.0, 1.0, 0.45 * group.flash_frames / FLASH_FRAMES))
			if show_hints:
				draw_rect(Rect2(top_left + Vector2(0.5, 0.5), tile - Vector2.ONE), HINT, false, 1.0)


## One jagged crack across a tile, the same every time for [param seed_value].
func _draw_crack(top_left: Vector2, tile: Vector2, seed_value: int) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var point: Vector2 = Vector2(rng.randi_range(2, int(tile.x) - 3), rng.randi_range(1, 3))
	var heading: float = rng.randf_range(-0.6, 0.6)
	for step: int in 4:
		var next: Vector2 = point + Vector2(sin(heading), cos(heading)) * rng.randf_range(3.0, 5.0)
		next = next.clamp(Vector2.ZERO, tile - Vector2.ONE).round()
		_draw_pixel_line(top_left + point, top_left + next)
		point = next
		heading += rng.randf_range(-1.0, 1.0)


func _draw_pixel_line(from: Vector2, to: Vector2) -> void:
	var steps: int = maxi(1, int(maxf(absf(to.x - from.x), absf(to.y - from.y))))
	for i: int in steps + 1:
		draw_rect(Rect2(from.lerp(to, float(i) / steps).floor(), Vector2.ONE), CRACK)
