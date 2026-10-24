extends SceneTree
## Re-saves scenes through Godot, like saving them in the editor: the files
## get the editor's canonical format (e.g. a unique_id on every node).
## Useful after editing .tscn files by hand.
## Usage (from the project folder):
##   godot --headless --path . --script res://tools/resave_scenes.gd -- res://world/rooms/storage.tscn [...]


func _initialize() -> void:
	for path in OS.get_cmdline_user_args():
		var scene: PackedScene = load(path)
		var root := scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
		var repacked := PackedScene.new()
		repacked.pack(root)
		var err := ResourceSaver.save(repacked, path)
		root.free()
		print("%s %s" % ["Saved" if err == OK else "FAILED", path])
	quit()
