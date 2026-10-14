extends GutTest
## Project wiring: autoloads, display settings and the main scene (ENG-002, ENG-007, ENG-008).

const AUTOLOADS: PackedStringArray = [
	"Settings", "Events", "Db", "Game", "SaveSystem", "WorldMap", "Audio", "SceneRouter",
]


func test_autoloads_are_loaded() -> void:
	for autoload_name: String in AUTOLOADS:
		assert_true(get_tree().root.has_node(autoload_name), "autoload %s missing" % autoload_name)


func test_display_is_pixel_perfect_640x360() -> void:
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_width"), 640)
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_height"), 360)
	assert_eq(ProjectSettings.get_setting("display/window/stretch/mode"), "viewport")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/scale_mode"), "integer")
	assert_eq(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter"), 0)


func test_main_scene_has_required_layers() -> void:
	var packed: PackedScene = load(ProjectSettings.get_setting("application/run/main_scene"))
	assert_not_null(packed, "main scene should load")
	var main: Node = packed.instantiate()
	add_child_autofree(main)
	assert_true(main.get_node("World") is Node2D, "World node")
	var expected_layers: Dictionary[String, int] = {"HUD": 10, "Menus": 20, "Transition": 30, "Debug": 99}
	for layer_name: String in expected_layers:
		var layer: CanvasLayer = main.get_node(layer_name) as CanvasLayer
		assert_not_null(layer, "%s CanvasLayer" % layer_name)
		if layer != null:
			assert_eq(layer.layer, expected_layers[layer_name], "%s layer index" % layer_name)
