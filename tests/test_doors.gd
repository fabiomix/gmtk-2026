extends "res://tests/test_base.gd"
## Warps through every door of the map; the locked badge door blocks its tile.
## Map: Cell - Corridor - {Archive north, Storage south, Laboratory east},
## Laboratory - (badge door) - Exit room.


func run_tests() -> void:
	await go(&"move_right", CORRIDOR, Vector2i(1, 2), Vector2i.RIGHT, "cell -> corridor")
	await go(&"move_left", CELL, Vector2i(5, 3), Vector2i.LEFT, "corridor -> cell")
	await go(&"move_right", CORRIDOR, Vector2i(1, 2), Vector2i.RIGHT, "cell -> corridor again")

	await walk_to(CORRIDOR, Vector2i(9, 2))
	await go(&"move_up", ARCHIVE, Vector2i(5, 5), Vector2i.UP, "corridor -> archive")
	await go(&"move_down", CORRIDOR, Vector2i(9, 1), Vector2i.DOWN, "archive -> corridor")
	await go(&"move_down", STORAGE, Vector2i(5, 1), Vector2i.DOWN, "corridor -> storage")
	await go(&"move_up", CORRIDOR, Vector2i(9, 3), Vector2i.UP, "storage -> corridor")

	await walk_to(CORRIDOR, Vector2i(9, 2))
	await go(&"move_right", LAB, Vector2i(1, 4), Vector2i.RIGHT, "corridor -> lab")

	await walk_to(LAB, Vector2i(12, 4))
	await face(Vector2i.RIGHT)
	check("locked badge door blocks its tile", tile_of_player(LAB), Vector2i(12, 4))
	check("no warp through the locked door", world._is_warping, false)

	await go(&"move_left", CORRIDOR, Vector2i(16, 2), Vector2i.LEFT, "lab -> corridor")
	check("fade transparent again", world.get_node("ScreenFade/Black").modulate.a, 0.0)


## Walks into a door and checks where the player arrives and faces.
func go(action: StringName, room: Vector2, tile: Vector2i, facing: Vector2i, label: String) -> void:
	var warped := await walk_into_door(action)
	check("warp " + label, warped, true)
	check("arrival tile " + label, tile_of_player(room), tile)
	check("facing " + label, player.facing, facing)
