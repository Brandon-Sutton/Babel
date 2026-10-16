extends Node
## Boot scene. Owns the World node (rooms and the player live under it) and the
## CanvasLayers for HUD, menus, transitions and debug listed in CLAUDE.md. Until
## SceneRouter handles room changes (WLD-002) it loads [member start_room], continues
## from the active save slot if there is one, and on death returns the player to the
## last save (or the room's spawn point when nothing has been saved), like Symphony of
## the Night. A room is any scene in the "room" group with a [code]spawn_point[/code]
## and camera [code]bounds[/code].

const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")
## Rooms the debug key F6 cycles through (ENG-019 first step), from the start room on.
const DEBUG_ROOMS: Array[String] = [
	"res://scenes/world/rooms/test/sandbox_room.tscn",
	"res://scenes/world/rooms/test/boss_arena_room.tscn",
]

@export var start_room: PackedScene = preload("res://scenes/world/rooms/test/sandbox_room.tscn")
## Resume from SaveSystem.active_slot at boot (tests turn this off).
@export var continue_from_save: bool = true

var player: Player
var room: Node2D

## The scene of the room loaded now (reloaded when Elam dies).
var _room_scene: PackedScene

@onready var _world: Node2D = %World


func _ready() -> void:
	SceneRouter.register_world(_world)
	_room_scene = start_room
	_load_room()
	player = PLAYER_SCENE.instantiate() as Player
	_world.add_child(player)
	player.respawn_requested.connect(_on_respawn_requested)
	var resume: Vector2 = _resume_from_save() if continue_from_save else Vector2.INF
	_place_player(resume if resume != Vector2.INF else _spawn_point())


func _load_room() -> void:
	room = _room_scene.instantiate() as Node2D
	_world.add_child(room)
	_world.move_child(room, 0)


## Replaces the current room with [param scene] and puts Elam at its spawn point (a debug
## warp until rooms connect through exits, WLD-002).
func warp_to(scene: PackedScene) -> void:
	_world.remove_child(room)
	room.queue_free()
	_room_scene = scene
	_load_room()
	Game.stats.full_restore()
	_place_player(_spawn_point())


## Warps to the next room of DEBUG_ROOMS (F6).
func warp_next_room() -> void:
	var index: int = DEBUG_ROOMS.find(_room_scene.resource_path)
	warp_to(load(DEBUG_ROOMS[(index + 1) % DEBUG_ROOMS.size()]) as PackedScene)


## Loads the active save into Game. Returns where to resume, or Vector2.INF if there is
## no usable save.
func _resume_from_save() -> Vector2:
	var data: Dictionary = SaveSystem.load_game(SaveSystem.active_slot)
	if data.is_empty():
		return Vector2.INF
	SaveSystem.apply_save(data)
	return SaveSystem.saved_position(data)


func _spawn_point() -> Vector2:
	var at: Variant = room.get(&"spawn_point")
	return room.to_global(at) if at is Vector2 else room.global_position


func _place_player(at: Vector2) -> void:
	player.respawn_at(at)
	var bounds: Variant = room.get(&"bounds")
	if bounds is Rect2:
		CameraLimits.apply(player.camera, Rect2(room.to_global((bounds as Rect2).position), (bounds as Rect2).size))
	player.camera.reset_smoothing()


func _on_respawn_requested() -> void:
	_world.remove_child(room)
	room.queue_free()
	_load_room()
	var resume: Vector2 = _resume_from_save() if continue_from_save else Vector2.INF
	if resume == Vector2.INF:
		Game.stats.full_restore()
		resume = _spawn_point()
	_place_player(resume)
