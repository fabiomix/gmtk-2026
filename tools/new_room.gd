extends SceneTree
## Creates a new empty room scene: floor surrounded by walls, with optional
## gaps in the wall where doors will go and optional crates (furniture).
## Doors and items are added afterwards in the editor (or by hand in the .tscn).
##
## Usage (from the project folder):
##   godot --headless --path . --script res://tools/new_room.gd -- <Name> <width> <height> [x,y ...] [crate:x,y ...]
##   x,y        = gap in the wall (floor tile) where a door will go
##   crate:x,y  = crate tile (solid furniture)
## Example:
##   godot --headless --path . --script res://tools/new_room.gd -- Archive 10 7 5,6 crate:1,1
## Creates res://world/rooms/archive.tscn (refuses to overwrite an existing file).

const FLOOR := Vector2i(0, 0)
const WALL := Vector2i(1, 0)
const CRATE := Vector2i(2, 0)


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 3:
		push_error("Usage: -- <Name> <width> <height> [x,y ...] [crate:x,y ...]")
		quit(1)
		return

	var room_name := args[0]
	var size := Vector2i(int(args[1]), int(args[2]))
	var path := "res://world/rooms/%s.tscn" % room_name.to_snake_case()
	if FileAccess.file_exists(path):
		push_error("%s already exists, not overwriting." % path)
		quit(1)
		return

	var room := Node2D.new()
	room.name = room_name
	var layer := TileMapLayer.new()
	layer.name = "Tiles"
	layer.tile_set = load("res://world/tiles/lab_tileset.tres")
	room.add_child(layer)
	layer.owner = room

	for x in size.x:
		for y in size.y:
			var border := x == 0 or y == 0 or x == size.x - 1 or y == size.y - 1
			layer.set_cell(Vector2i(x, y), 0, WALL if border else FLOOR)
	for token in args.slice(3):
		var tile := FLOOR
		if token.begins_with("crate:"):
			tile = CRATE
			token = token.trim_prefix("crate:")
		var xy := token.split(",")
		layer.set_cell(Vector2i(int(xy[0]), int(xy[1])), 0, tile)

	for child_name in ["Doors", "Items"]:
		var child := Node2D.new()
		child.name = child_name
		room.add_child(child)
		child.owner = room

	var packed := PackedScene.new()
	packed.pack(room)
	ResourceSaver.save(packed, path)
	room.free()
	print("Created ", path)
	quit()
