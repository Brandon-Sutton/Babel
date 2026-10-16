class_name BossPart
extends Node2D
## A severable piece of a boss (BOSS-030), the one Fear & Hunger mechanic: an arm, a
## wing, a head, a mask or a plate of armour with its own HP and hurtbox. A hit on it
## damages the part and the boss (Boss.hit_part). At 0 HP it is torn away: its sprite
## falls off as a SeveredPiece, the spritework drawn beneath it shows (a stump, bone,
## flesh, or something worse), and its hurtbox goes. The boss decides what the loss
## changes. Both images share one canvas and [member pivot] (ART_BIBLE §6.2), and both
## are authored facing right; the boss mirrors its whole body when facing left.

## Emitted once when the part's HP reaches 0.
signal severed(part: BossPart)

## Name the boss's patterns refer to (BossPattern.requires_part / needs_severed).
@export var part_id: StringName
@export var max_hp: int = 60
## Extra damage the boss takes when the part is torn off.
@export var sever_damage: int = 30
## Where the part can be hit, in the part's coordinates (facing right).
@export var hurt_rect: Rect2 = Rect2(-8, -8, 16, 16)
@export var blood: Color = Color("8a1428")

var hp: int = 0
var _severed: bool = false
var _intact: Sprite2D
var _beneath: Sprite2D
var _pivot: Vector2 = Vector2.ZERO
var _hurtbox: Hurtbox


func _ready() -> void:
	hp = max_hp
	use_parent_material = true
	_beneath = _make_sprite("Beneath")
	_beneath.visible = false
	_intact = _make_sprite("Intact")
	_hurtbox = Hurtbox.new()
	_hurtbox.name = "Hurtbox"
	_hurtbox.collision_layer = 1 << 5
	_hurtbox.collision_mask = 0
	_hurtbox.monitoring = false
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = hurt_rect.size
	shape.shape = rect
	shape.position = hurt_rect.get_center()
	_hurtbox.add_child(shape)
	add_child(_hurtbox)


## Sets the part's art: [param intact] as it starts, [param beneath] once it is torn off,
## both with [param pivot] (the texture pixel at this node's origin).
func set_art(intact: Texture2D, beneath: Texture2D, pivot: Vector2) -> void:
	_pivot = pivot
	_intact.texture = intact
	_intact.offset = -pivot
	_beneath.texture = beneath
	_beneath.offset = -pivot


## The hurtbox, so the boss can route its hits (Boss.hit_part).
func hurtbox() -> Hurtbox:
	return _hurtbox


func is_severed() -> bool:
	return _severed


## Takes [param amount] damage. Returns true if this tore the part off.
func take(amount: int) -> bool:
	if _severed or amount <= 0:
		return false
	hp = maxi(0, hp - amount)
	return hp == 0


## Tears the part off: the intact sprite falls away and what lies beneath shows. The
## piece lands on the floor at [param floor_y] (global); [param direction] is the way it
## is flung (+1 right, -1 left). Emits [signal severed].
func sever(floor_y: float, direction: float) -> void:
	if _severed:
		return
	_severed = true
	hp = 0
	_intact.visible = false
	_beneath.visible = true
	_hurtbox.set_deferred(&"monitorable", false)
	if _intact.texture != null:
		var flipped: bool = global_transform.x.x < 0.0
		SeveredPiece.spawn(get_tree(), _intact.texture, global_position, _pivot, flipped, floor_y, blood, direction)
	severed.emit(self)


func _make_sprite(sprite_name: String) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = sprite_name
	sprite.centered = false
	sprite.use_parent_material = true
	add_child(sprite)
	return sprite
