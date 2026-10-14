class_name FileScan
## Recursive file listing that works both in the editor and in exported builds.


## Returns every file under [param root] (recursively) whose name ends with one of
## [param extensions], e.g. [code][".tres", ".res"][/code]. Directories listed in
## [param skip_dirs] and hidden directories (starting with ".") are not entered.
## Exported builds list resources as [code]<file>.remap[/code]; those are reported
## under their original name so they can be passed straight to [method @GDScript.load].
static func list_files(
		root: String,
		extensions: PackedStringArray,
		skip_dirs: PackedStringArray = PackedStringArray()
) -> PackedStringArray:
	var found: PackedStringArray = []
	for file_name: String in DirAccess.get_files_at(root):
		var original: String = file_name.trim_suffix(".remap")
		for ext: String in extensions:
			if original.ends_with(ext):
				found.append(root.path_join(original))
				break
	for dir_name: String in DirAccess.get_directories_at(root):
		var sub: String = root.path_join(dir_name)
		if dir_name.begins_with(".") or sub in skip_dirs:
			continue
		found.append_array(list_files(sub, extensions, skip_dirs))
	return found
