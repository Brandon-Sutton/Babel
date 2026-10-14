extends Node
## Boot scene. Owns the World node (rooms and the player live under it) and the
## CanvasLayers for HUD, menus, transitions and debug listed in CLAUDE.md. Until
## SceneRouter handles room changes (WLD-002) it loads [member start_room], spawns the
## player there and respawns everything when the player dies.

const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")

@export var start_room: PackedScene = preload("res://scenes/world/rooms/test/sandbox_room.tscn")

var player: Player
var room: SandboxRoom

@onready var _world: Node2D = %World


func _ready() -> void:
	SceneRouter.register_world(_world)
	_load_room()
	player = PLAYER_SCENE.instantiate() as Player
	_world.add_child(player)
	player.respawn_requested.connect(_on_respawn_requested)
	_place_player()


func _load_room() -> void:
	room = start_room.instantiate() as SandboxRoom
	_world.add_child(room)
	_world.move_child(room, 0)


func _place_player() -> void:
	player.respawn_at(room.spawn_point)
	var camera: Camera2D = player.camera
	camera.limit_left = int(room.bounds.position.x)
	camera.limit_top = int(room.bounds.position.y)
	camera.limit_right = int(room.bounds.end.x)
	camera.limit_bottom = int(room.bounds.end.y)
	camera.reset_smoothing()


func _on_respawn_requested() -> void:
	room.queue_free()
	_load_room()
	Game.stats.full_restore()
	_place_player()
