extends SceneTree
## Loads every script in the kit, the preview and the tests, which compiles each without running
## it, so Godot reports any that fails to parse. Run by tools/check.sh, which searches the output.

const FOLDERS: Array[String] = ["res://cove_kit", "res://preview", "res://tests", "res://tests/fixtures"]


func _init() -> void:
	var count := 0
	for folder in FOLDERS:
		for file in DirAccess.get_files_at(folder):
			if file.get_extension() == "gd":
				load(folder.path_join(file))
				count += 1
	print("Loaded %d scripts" % count)
	quit()
