extends GutTest
## FileScan.list_files: extension filtering, recursion and skipped directories.


func test_finds_files_by_extension_recursively() -> void:
	var found: PackedStringArray = FileScan.list_files("res://autoload", [".gd"])
	assert_has(found, "res://autoload/game.gd")
	assert_has(found, "res://autoload/scene_router.gd")


func test_ignores_other_extensions() -> void:
	var found: PackedStringArray = FileScan.list_files("res://autoload", [".tscn"])
	assert_eq(found.size(), 0)


func test_skips_listed_directories() -> void:
	var found: PackedStringArray = FileScan.list_files("res://", [".gd"], ["res://addons"])
	for path: String in found:
		assert_false(path.begins_with("res://addons"), "%s should be skipped" % path)
	assert_has(found, "res://autoload/db.gd")
