class_name MaskSpawner
extends Node2D
## Keeps Humbaba Masks flying in from the screen edges while the player is inside
## [member zone] (x range in global pixels), like Symphony of the Night's Medusa heads.

@export var mask_scene: PackedScene = preload("res://scenes/actors/enemies/humbaba_mask/humbaba_mask.tscn")
## Horizontal extent (global x from, to) where masks spawn.
@export var zone: Vector2 = Vector2(960.0, 1600.0)
## Global y band (top, bottom) masks fly through.
@export var height_band: Vector2 = Vector2(200.0, 260.0)
@export var interval_frames: int = 110
@export var max_alive: int = 3

var _cooldown: int = 60
## Instance ids of spawned masks (ids stay safe to check after the mask is freed).
var _alive: Array[int] = []


func _physics_process(_delta: float) -> void:
	var still_alive: Array[int] = []
	for id: int in _alive:
		if is_instance_id_valid(id):
			still_alive.append(id)
	_alive = still_alive
	var player: Player = get_tree().get_first_node_in_group(&"player") as Player
	if player == null or player.global_position.x < zone.x or player.global_position.x > zone.y:
		return
	_cooldown -= 1
	if _cooldown > 0 or _alive.size() >= max_alive:
		return
	_cooldown = interval_frames
	var from_left: bool = randf() < 0.5
	var mask: Enemy = mask_scene.instantiate() as Enemy
	mask.facing = 1 if from_left else -1
	get_parent().add_child(mask)
	mask.global_position = Vector2(player.global_position.x + (-340.0 if from_left else 340.0),
			randf_range(height_band.x, height_band.y))
	_alive.append(mask.get_instance_id())
