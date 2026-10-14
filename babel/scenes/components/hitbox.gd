class_name Hitbox
extends Area2D
## Deals damage to Hurtboxes it overlaps while [member active] (CBT-001). One-shot
## hitboxes (weapon swings) hit each hurtbox once per activation; [member continuous]
## ones (contact damage) keep hitting and rely on the target's invulnerability frames.
## Layers come from the scene: player attacks mask enemy_hurtbox, enemy attacks mask
## player_hurtbox (CLAUDE.md collision table).

## Emitted when a hit was accepted by a hurtbox.
signal hit_landed(hurtbox: Hurtbox, info: DamageInfo)

@export var continuous: bool = false
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
