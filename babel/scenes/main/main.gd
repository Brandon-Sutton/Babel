extends Node
## Boot scene. Owns the World node (rooms and the player live under it) and the
## CanvasLayers for HUD, menus, transitions and debug listed in CLAUDE.md. Until
## SceneRouter handles room changes (WLD-002) it loads [member start_room], continues
## from the active save slot if there is one, and on death returns the player to the
## last save (or the room's spawn point when nothing has been saved), like Symphony of
## the Night.

const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")

@export var start_room: PackedScene = preload("res://scenes/world/rooms/test/sandbox_room.tscn")
## Resume from SaveSystem.active_slot at boot (tests turn this off).
@export var continue_from_save: bool = true

var player: Player
var room: SandboxRoom

@onready var _world: Node2D = %World


func _ready() -> void:
	SceneRouter.register_world(_world)
	_load_room()
	player = PLAYER_SCENE.instantiate() as Player
	_world.add_child(player)
	player.respawn_requested.connect(_on_respawn_requested)
	var resume: Vector2 = _resume_from_save() if continue_from_save else Vector2.INF
	_place_player(resume if resume != Vector2.INF else room.spawn_point)


func _load_room() -> void:
	room = start_room.instantiate() as SandboxRoom
	_world.add_child(room)
	_world.move_child(room, 0)


## Loads the active save into Game. Returns where to resume, or Vector2.INF if there is
## no usable save.
func _resume_from_save() -> Vector2:
	var data: Dictionary = SaveSystem.load_game(SaveSystem.active_slot)
	if data.is_empty():
		return Vector2.INF
	SaveSystem.apply_save(data)
	return SaveSystem.saved_position(data)


func _place_player(at: Vector2) -> void:
	player.respawn_at(at)
	var camera: Camera2D = player.camera
	camera.limit_left = int(room.bounds.position.x)
	camera.limit_top = int(room.bounds.position.y)
	camera.limit_right = int(room.bounds.end.x)
	camera.limit_bottom = int(room.bounds.end.y)
	camera.reset_smoothing()


func _on_respawn_requested() -> void:
	room.queue_free()
	_load_room()
	var resume: Vector2 = _resume_from_save() if continue_from_save else Vector2.INF
	if resume == Vector2.INF:
		Game.stats.full_restore()
		resume = room.spawn_point
	_place_player(resume)
