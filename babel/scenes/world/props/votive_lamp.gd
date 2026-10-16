class_name VotiveLamp
extends Node2D
## A votive lamp on a bronze stand (WLD-007), Symphony of the Night's candles: one hit
## breaks it and drops something from [member loot]. Lamps come back when the room
## reloads.

@export var loot: LootTable = preload("res://data/loot/votive_lamp.tres")
## Item weight factor while Elam owns the Wanderer's Cube (REL-009).
@export var cube_item_factor: float = 2.0

var _time: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var _hurtbox: Hurtbox = %Hurtbox


func _ready() -> void:
	_rng.randomize()
	_hurtbox.owner_node = self
	_hurtbox.handler = _on_hit


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _on_hit(info: DamageInfo) -> bool:
	HitSpark.spawn(get_tree(), info.position, Color("fbe69b"))
	var item_factor: float = cube_item_factor if Game.has_ability(&"lamp_items") else 1.0
	var drop: LootTable.Drop = loot.roll(_rng, Game.stats.total(&"luck"), item_factor)
	Pickup.spawn(get_parent(), global_position + Vector2(0, -36), drop)
	queue_free()
	return true


func _draw() -> void:
	# Warm halo behind the flame (the Sprite2D child draws on top).
	var flicker: float = 0.75 + 0.25 * sin(_time * 13.0) * sin(_time * 7.0)
	draw_rect(Rect2(-6, -50, 12, 12), Color(1.0, 0.7, 0.3, 0.12 * flicker))
	draw_rect(Rect2(-4, -48, 8, 8), Color(1.0, 0.8, 0.4, 0.18 * flicker))
