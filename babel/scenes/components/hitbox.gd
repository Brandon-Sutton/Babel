class_name Hitbox
extends Area2D
## Deals damage to Hurtboxes it overlaps while [member active] (CBT-001). One-shot
## hitboxes (weapon swings) hit each hurtbox once per activation; [member continuous]
## ones (contact damage) keep hitting and rely on the target's invulnerability frames.
## Layers come from the scene: player attacks mask enemy_hurtbox, enemy attacks mask
## player_hurtbox (CLAUDE.md collision table). Level geometry blocks hits (CBT-013): a
## hurtbox only counts when a line from the attacker's body, at the hitbox's height,
## reaches it without crossing a world tile. One-way platforms don't block. A hurtbox
## that is itself level geometry (a breakable wall) is reached when the ray stops on it.

## Emitted when a hit was accepted by a hurtbox.
signal hit_landed(hurtbox: Hurtbox, info: DamageInfo)

## Physics layer of solid level geometry (CLAUDE.md: layer 1, world).
const WORLD_MASK: int = 1
## Most tiles of a breakable wall aimed at by the wall check.
const MAX_TERRAIN_TARGETS: int = 16

@export var continuous: bool = false
## Hits need a clear line through the level from the attacker (CBT-013).
@export var blocked_by_walls: bool = true
@export var active: bool = false:
	set = set_active

var attack: int = 0
var knockback: float = 120.0
var hit_stop_frames: int = 0
## Chance in 0..1 that a hit is critical.
var crit_chance: float = 0.0
## Node whose own Hurtbox must never be hit by this hitbox.
var owner_node: Node

var _already_hit: Dictionary[Hurtbox, bool] = {}


func _ready() -> void:
	monitoring = true
	monitorable = false


func set_active(value: bool) -> void:
	active = value
	if value:
		_already_hit.clear()


func _physics_process(_delta: float) -> void:
	if not active:
		return
	for area: Area2D in get_overlapping_areas():
		var hurtbox: Hurtbox = area as Hurtbox
		if hurtbox == null or (owner_node != null and hurtbox.owner_node == owner_node):
			continue
		if not continuous and _already_hit.has(hurtbox):
			continue
		# Not marked as hit: the target can still be struck if it steps into the open
		# while the hitbox is active.
		if blocked_by_walls and not has_clear_line(hurtbox):
			continue
		_already_hit[hurtbox] = true
		var info: DamageInfo = DamageInfo.new()
		info.attack = attack
		info.critical = randf() < crit_chance
		info.knockback = knockback
		info.direction = signf(hurtbox.global_position.x - global_position.x)
		if info.direction == 0.0:
			info.direction = 1.0
		info.hit_stop_frames = hit_stop_frames
		info.position = (global_position + hurtbox.global_position) / 2.0
		info.source = owner_node
		if hurtbox.receive_hit(info):
			hit_landed.emit(hurtbox, info)


## True if nothing solid stands between the attacker and [param hurtbox]: a ray from the
## attacker's centre line, at this hitbox's height, reaches the hurtbox's centre or its
## nearest point, or for level geometry, stops on the geometry itself.
func has_clear_line(hurtbox: Hurtbox) -> bool:
	var centre: Vector2 = _shape_centre(self)
	var origin: Vector2 = centre
	var attacker: Node2D = owner_node as Node2D
	if attacker != null:
		origin = Vector2(attacker.global_position.x, centre.y)
	var target: Vector2 = _shape_centre(hurtbox)
	var targets: Array[Vector2] = [target]
	var rect: Rect2 = _shape_rect(hurtbox)
	if rect.has_area():
		targets.append(origin.clamp(rect.position, rect.end))
	for terrain: Rect2 in hurtbox.terrain_rects.slice(0, MAX_TERRAIN_TARGETS):
		targets.append(terrain.get_center())
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	for point: Vector2 in targets:
		var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(origin, point, WORLD_MASK)
		var hit: Dictionary = space.intersect_ray(query)
		if hit.is_empty() or hurtbox.is_on_terrain(hit["position"]):
			return true
	return false


## Global centre of [param area]'s first collision shape (the area's own position if none).
static func _shape_centre(area: Area2D) -> Vector2:
	for child: Node in area.get_children():
		if child is CollisionShape2D:
			return (child as CollisionShape2D).global_position
	return area.global_position


## Global bounds of [param area]'s first rectangle shape (empty if it has none).
static func _shape_rect(area: Area2D) -> Rect2:
	for child: Node in area.get_children():
		var shape_node: CollisionShape2D = child as CollisionShape2D
		if shape_node != null and shape_node.shape is RectangleShape2D:
			var size: Vector2 = (shape_node.shape as RectangleShape2D).size
			return Rect2(shape_node.global_position - size / 2.0, size)
	return Rect2()
