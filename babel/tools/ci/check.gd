extends SceneTree
## Project-wide load check (ENG-010). Loads every script, scene, resource and shader
## outside addons/ and art_src/ and exits with code 1 if anything fails to load or the
## engine logs an error while loading (parse errors, warnings-as-errors, missing
## dependencies). Run `--import` first so class_name references resolve.
##
## Usage, from the repo root:
##   godot --headless --path babel -s res://tools/ci/check.gd

const _Scan := preload("res://scripts/util/file_scan.gd")
const EXTENSIONS: PackedStringArray = [".gd", ".tscn", ".tres", ".gdshader"]
const SKIP_DIRS: PackedStringArray = ["res://addons", "res://art_src"]


## Collects engine errors (not warnings) logged while the check runs.
class ErrorCollector extends Logger:
	var errors: PackedStringArray = []
	var _mutex: Mutex = Mutex.new()

	func _log_error(
			_function: String, file: String, line: int, code: String, rationale: String,
			_editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]
	) -> void:
		if error_type == ERROR_TYPE_WARNING:
			return
		_mutex.lock()
		errors.append("%s:%d: %s" % [file, line, rationale if not rationale.is_empty() else code])
		_mutex.unlock()


func _initialize() -> void:
	var started_ms: int = Time.get_ticks_msec()
	var collector: ErrorCollector = ErrorCollector.new()
	OS.add_logger(collector)

	var paths: PackedStringArray = _Scan.list_files("res://", EXTENSIONS, SKIP_DIRS)
	# Re-loading the running main-loop script with CACHE_MODE_IGNORE crashes the engine.
	var self_path: String = (get_script() as Script).resource_path
	var failures: PackedStringArray = []
	for path: String in paths:
		if path == self_path:
			continue
		var errors_before: int = collector.errors.size()
		var res: Resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if res == null:
			failures.append("%s: failed to load" % path)
		elif res is PackedScene and not (res as PackedScene).can_instantiate():
			failures.append("%s: scene cannot be instantiated" % path)
		elif collector.errors.size() > errors_before:
			failures.append("%s: errors while loading" % path)

	OS.remove_logger(collector)
	var elapsed_ms: int = Time.get_ticks_msec() - started_ms
	if failures.is_empty() and collector.errors.is_empty():
		print("check: OK - %d files loaded in %d ms." % [paths.size(), elapsed_ms])
		quit(0)
		return
	for failure: String in failures:
		printerr("check: FAIL ", failure)
	for error: String in collector.errors:
		printerr("check: error ", error)
	printerr("check: %d failing file(s) of %d, %d engine error(s), %d ms." % [
		failures.size(), paths.size(), collector.errors.size(), elapsed_ms])
	quit(1)
