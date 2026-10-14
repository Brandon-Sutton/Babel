extends SceneTree
## Applies BABEL's project settings and saves project.godot: display and pixel-perfect
## rendering, physics, GDScript warning levels, 2D collision layer names, the input map,
## autoloads (in load order) and the main scene. Safe to re-run; it is the reference for
## what these settings should be (see CLAUDE.md).
##
## Usage, from the repo root:
##   godot --headless --path babel -s res://tools/setup/configure_project.gd

const MAIN_SCENE: String = "res://scenes/main/main.tscn"

## Load order matters: later autoloads may use earlier ones in _ready().
const AUTOLOADS: PackedStringArray = [
	"Settings", "Events", "Db", "Game", "SaveSystem", "WorldMap", "Audio", "SceneRouter",
]

const LAYER_NAMES: PackedStringArray = [
	"world", "platform", "player", "enemy", "player_hurtbox", "enemy_hurtbox",
	"player_hitbox", "enemy_hitbox", "pickup", "interact", "trigger", "breakable",
	"water", "hazard",
]

const WARN_IGNORE: int = 0
const WARN_WARN: int = 1
const WARN_ERROR: int = 2


func _initialize() -> void:
	_apply_settings()
	_apply_layer_names()
	_apply_input_map()
	_apply_autoloads()
	var err: Error = ProjectSettings.save()
	if err != OK:
		push_error("configure_project: saving project.godot failed: %s" % error_string(err))
		quit(1)
		return
	print("configure_project: project.godot updated.")
	quit()


func _apply_settings() -> void:
	var settings: Dictionary[String, Variant] = {
		# Display: 640x360 internal resolution, integer scaling only (CLAUDE.md).
		"display/window/size/viewport_width": 640,
		"display/window/size/viewport_height": 360,
		"display/window/size/window_width_override": 1920,
		"display/window/size/window_height_override": 1080,
		"display/window/stretch/mode": "viewport",
		"display/window/stretch/scale_mode": "integer",
		# Rendering: crisp pixels, snapped transforms, HDR 2D for magic glow.
		"rendering/textures/canvas_textures/default_texture_filter": 0,
		"rendering/2d/snap/snap_2d_transforms_to_pixel": true,
		"rendering/viewport/hdr_2d": true,
		"rendering/environment/defaults/default_clear_color": Color(0.043, 0.039, 0.063),
		# Physics: 60 Hz with interpolation for smooth high-refresh rendering.
		"physics/common/physics_ticks_per_second": 60,
		"physics/common/physics_interpolation": true,
		# GDScript: static typing is mandatory; unsafe access is flagged.
		"debug/gdscript/warnings/untyped_declaration": WARN_ERROR,
		"debug/gdscript/warnings/unsafe_property_access": WARN_WARN,
		"debug/gdscript/warnings/unsafe_method_access": WARN_WARN,
		"debug/gdscript/warnings/unsafe_cast": WARN_WARN,
		"debug/gdscript/warnings/unsafe_call_argument": WARN_WARN,
		# Boot scene.
		"application/run/main_scene": MAIN_SCENE,
		# Editor plugins (GUT, ENG-009).
		"editor_plugins/enabled": PackedStringArray(["res://addons/gut/plugin.cfg"]),
	}
	for key: String in settings:
		ProjectSettings.set_setting(key, settings[key])


func _apply_layer_names() -> void:
	for i: int in LAYER_NAMES.size():
		ProjectSettings.set_setting("layer_names/2d_physics/layer_%d" % (i + 1), LAYER_NAMES[i])


func _apply_input_map() -> void:
	# Defaults from the CLAUDE.md input table; players can rebind everything (UI-013).
	_set_action("move_left", 0.25, [_key(KEY_LEFT), _joy_button(JOY_BUTTON_DPAD_LEFT), _joy_axis(JOY_AXIS_LEFT_X, -1.0)])
	_set_action("move_right", 0.25, [_key(KEY_RIGHT), _joy_button(JOY_BUTTON_DPAD_RIGHT), _joy_axis(JOY_AXIS_LEFT_X, 1.0)])
	_set_action("move_up", 0.25, [_key(KEY_UP), _joy_button(JOY_BUTTON_DPAD_UP), _joy_axis(JOY_AXIS_LEFT_Y, -1.0)])
	_set_action("move_down", 0.25, [_key(KEY_DOWN), _joy_button(JOY_BUTTON_DPAD_DOWN), _joy_axis(JOY_AXIS_LEFT_Y, 1.0)])
	_set_action("jump", 0.5, [_key(KEY_Z), _joy_button(JOY_BUTTON_A)])
	_set_action("attack_right", 0.5, [_key(KEY_X), _joy_button(JOY_BUTTON_X)])
	_set_action("attack_left", 0.5, [_key(KEY_C), _joy_button(JOY_BUTTON_B)])
	_set_action("backdash", 0.5, [_key(KEY_SHIFT), _joy_button(JOY_BUTTON_Y)])
	_set_action("relic_arm", 0.5, [_key(KEY_V), _joy_axis(JOY_AXIS_TRIGGER_LEFT, 1.0)])
	_set_action("form_dust", 0.5, [_key(KEY_A), _joy_axis(JOY_AXIS_TRIGGER_RIGHT, 1.0)])
	_set_action("form_raven", 0.5, [_key(KEY_S), _joy_button(JOY_BUTTON_RIGHT_SHOULDER)])
	_set_action("form_lion", 0.5, [_key(KEY_D), _joy_button(JOY_BUTTON_LEFT_SHOULDER)])
	_set_action("map", 0.5, [_key(KEY_TAB), _joy_button(JOY_BUTTON_BACK)])
	_set_action("pause", 0.5, [_key(KEY_ESCAPE), _joy_button(JOY_BUTTON_START)])


func _apply_autoloads() -> void:
	# Clear first so re-runs keep the order in AUTOLOADS.
	for autoload_name: String in AUTOLOADS:
		if ProjectSettings.has_setting("autoload/" + autoload_name):
			ProjectSettings.clear("autoload/" + autoload_name)
	for autoload_name: String in AUTOLOADS:
		var path: String = "res://autoload/%s.gd" % autoload_name.to_snake_case()
		if not FileAccess.file_exists(path):
			push_warning("configure_project: missing %s, autoload %s skipped." % [path, autoload_name])
			continue
		ProjectSettings.set_setting("autoload/" + autoload_name, "*" + path)


func _set_action(action: String, deadzone: float, events: Array[InputEvent]) -> void:
	ProjectSettings.set_setting("input/" + action, {"deadzone": deadzone, "events": events})


func _key(keycode: Key) -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.device = -1
	event.physical_keycode = keycode
	return event


func _joy_button(button: JoyButton) -> InputEventJoypadButton:
	var event: InputEventJoypadButton = InputEventJoypadButton.new()
	event.device = -1
	event.button_index = button
	return event


func _joy_axis(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var event: InputEventJoypadMotion = InputEventJoypadMotion.new()
	event.device = -1
	event.axis = axis
	event.axis_value = value
	return event
