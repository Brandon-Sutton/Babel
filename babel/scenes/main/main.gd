extends Node
## Boot scene. Owns the World node (rooms and the player live under it) and the
## CanvasLayers for HUD, menus, transitions and debug listed in CLAUDE.md.

@onready var _world: Node2D = %World


func _ready() -> void:
	SceneRouter.register_world(_world)
