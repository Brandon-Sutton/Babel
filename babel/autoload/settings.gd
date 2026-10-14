extends Node
## Persistent user settings (video, audio, input remaps, accessibility, language),
## stored in [code]user://settings.cfg[/code]. UI-013 builds the settings screens on this.

## Emitted after a value changes through [method set_value].
signal changed(section: String, key: String)

const PATH: String = "user://settings.cfg"

var _config: ConfigFile = ConfigFile.new()


func _ready() -> void:
	load_settings()


## Loads settings from disk. A missing file is not an error: defaults apply.
func load_settings() -> void:
	var err: Error = _config.load(PATH)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		push_warning("Settings: could not load %s (%s); using defaults." % [PATH, error_string(err)])


## Writes the current settings to disk.
func save_settings() -> Error:
	return _config.save(PATH)


## Returns the stored value, or [param default] when nothing is stored.
func get_value(section: String, key: String, default: Variant = null) -> Variant:
	return _config.get_value(section, key, default)


## Stores a value in memory and emits [signal changed]. Call [method save_settings] to persist.
func set_value(section: String, key: String, value: Variant) -> void:
	_config.set_value(section, key, value)
	changed.emit(section, key)
