class_name Pickup
extends CharacterBody2D
## A drop from a lamp or enemy (INV-006): embers, shekels, an item or a Relic Arm. Pops
## out, falls to the floor, is pulled to the player when close, and blinks out after a
## while. Touching a Relic Arm swaps it for the one carried (SUB-011), which drops in
## its place and can't be picked up again straight away.

const SCENE_PATH: String = "res://scenes/world/pickups/pickup.tscn"
const MAGNET_RANGE: float = 40.0
const MAGNET_SPEED: float = 240.0
const LIFETIME_FRAMES: int = 600
const BLINK_FROM: int = 480
const GRAVITY: float = 900.0
## Frames before it can be collected (so it visibly pops out first).
const ARM_FRAMES: int = 12
const EMBER: Color = Color("ef6a6a")
const EMBER_CORE: Color = Color("fbe69b")
const GOLD: Color = Color("d4b06e")
const GOLD_DARK: Color = Color("82633f")

var kind: StringName = &"embers"
var amount: int = 1
var item_id: StringName = &""
## Frames before it can be collected; longer for a Relic Arm just swapped out.
var arm_frames: int = ARM_FRAMES
## Pulled toward the player when close (not for a Relic Arm, which must be touched).
var magnetic: bool = true
var _frame: int = 0

@onready var _collector: Area2D = %Collector


## Drops [param drop] at [param at] (global position) under [param parent].
static func spawn(parent: Node, at: Vector2, drop: LootTable.Drop) -> void:
	if drop == null or drop.kind == &"nothing":
		return
	var pickup: Pickup = (load(SCENE_PATH) as PackedScene).instantiate() as Pickup
	pickup.kind = drop.kind
	pickup.amount = drop.amount
	pickup.item_id = drop.item_id
	pickup.velocity = Vector2(randf_range(-50.0, 50.0), -200.0)
	var origin: Vector2 = (parent as Node2D).global_position if parent is Node2D else Vector2.ZERO
	pickup.position = at - origin
	parent.add_child.call_deferred(pickup)


## Drops the Relic Arm [param arm_id] at [param at], collectable after [param delay] frames.
static func spawn_relic_arm(parent: Node, at: Vector2, arm_id: StringName, delay: int) -> Pickup:
	var pickup: Pickup = (load(SCENE_PATH) as PackedScene).instantiate() as Pickup
	pickup.kind = &"relic_arm"
	pickup.item_id = arm_id
	pickup.arm_frames = delay
	pickup.magnetic = false
	pickup.velocity = Vector2(0.0, -160.0)
	var origin: Vector2 = (parent as Node2D).global_position if parent is Node2D else Vector2.ZERO
	pickup.position = at - origin
	parent.add_child.call_deferred(pickup)
	return pickup


func _ready() -> void:
	_collector.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_frame += 1
	var player: Player = get_tree().get_first_node_in_group(&"player") as Player
	var target: Vector2 = player.global_position + Vector2(0, -30) if player != null else Vector2.ZERO
	if player != null and magnetic and _frame > arm_frames and global_position.distance_to(target) < MAGNET_RANGE:
		velocity = (target - global_position).normalized() * MAGNET_SPEED
		global_position += velocity * delta
	else:
		velocity.y = minf(velocity.y + GRAVITY * delta, 400.0)
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0.0, 12.0)
		move_and_slide()
	if _frame >= arm_frames and player != null and _collector.overlaps_body(player):
		_collect()
		return
	if _frame >= LIFETIME_FRAMES:
		queue_free()
	visible = _frame < BLINK_FROM or floori(_frame / 4.0) % 2 == 0
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if body is Player and _frame >= arm_frames:
		_collect()


func _collect() -> void:
	if is_queued_for_deletion():
		return
	match kind:
		&"embers":
			Game.stats.add_embers(amount)
			DamageNumber.spawn_text(get_tree(), global_position + Vector2(0, -6), "+%d" % amount, EMBER, 1, 30)
		&"shekels":
			Game.stats.add_shekels(amount)
			DamageNumber.spawn_text(get_tree(), global_position + Vector2(0, -6), "+%d" % amount, GOLD, 1, 30)
		&"item":
			Game.inventory.add(item_id)
			var found: ItemData = Game.item(item_id)
			Events.item_acquired.emit(item_id, 1)
			Events.notice.emit(found.display_name if found != null else String(item_id), "OBTAINED")
		&"relic_arm":
			var arm: RelicArmData = Game.item(item_id) as RelicArmData
			var previous: RelicArmData = Game.stats.relic_arm
			Game.stats.relic_arm = arm
			Game.stats.emit_changed()
			if previous != null and previous != arm:
				spawn_relic_arm(get_parent(), global_position, previous.id, 90)
			Events.notice.emit(arm.display_name if arm != null else String(item_id), tr("RELIC ARM"))
	queue_free()


func _draw() -> void:
	match kind:
		&"embers":
			var big: bool = amount > 1
			var h: float = 7.0 if big else 5.0
			draw_rect(Rect2(-2, -h, 4, h), EMBER)
			draw_rect(Rect2(-1, -h - 2, 2, 2), EMBER)
			draw_rect(Rect2(-1, -h + 2, 2, h - 3), EMBER_CORE)
		&"shekels":
			var size: float = 5.0 if amount < 10 else 7.0
			draw_rect(Rect2(-size / 2.0, -size, size, size), GOLD_DARK)
			draw_rect(Rect2(-size / 2.0 + 1, -size + 1, size - 2, size - 2), GOLD)
		&"item":
			var glow: float = 0.5 + 0.5 * sin(_frame * 0.2)
			draw_rect(Rect2(-5, -11, 10, 10), Color(EMBER_CORE, 0.2 + 0.25 * glow))
			draw_rect(Rect2(-3, -9, 6, 6), GOLD)
			draw_rect(Rect2(-1, -7, 2, 2), Color.WHITE)
		&"relic_arm":
			var arm: RelicArmData = Game.item(item_id) as RelicArmData
			var glow: float = 0.5 + 0.5 * sin(_frame * 0.2)
			draw_rect(Rect2(-7, -15, 14, 14), Color(Color("6c8ee0"), 0.2 + 0.3 * glow))
			draw_rect(Rect2(-5, -13, 10, 10), GOLD_DARK)
			draw_rect(Rect2(-4, -12, 8, 8), arm.color if arm != null else GOLD)
