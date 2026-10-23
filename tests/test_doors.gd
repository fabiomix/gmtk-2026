extends "res://tests/test_base.gd"
## Warps between Cell (0,0) and Corridor (1024,0); locked door blocks the tile.
## Cell door cell_east at (6,3); corridor_west at (0,2); corridor_north (locked) at (9,0).

const CORRIDOR := Vector2(1024, 0)


func run_tests() -> void:
	var warped := await walk_into_door(&"move_right")
	check("warp cell -> corridor", warped, true)
	check("arrived in front of corridor_west", tile_of_player(CORRIDOR), Vector2i(1, 2))
	check("facing into the corridor", player.facing, Vector2i.RIGHT)
	check("fade transparent again", world.get_node("ScreenFade/Black").modulate.a, 0.0)

	warped = await walk_into_door(&"move_left")
	check("warp corridor -> cell", warped, true)
	check("arrived in front of cell_east", tile_of_player(Vector2.ZERO), Vector2i(5, 3))
	check("facing into the cell", player.facing, Vector2i.LEFT)

	await walk_into_door(&"move_right")
	await step(&"move_right", 8)
	await step(&"move_up", 2)
	check("stopped below the locked door", tile_of_player(CORRIDOR), Vector2i(9, 1))
	check("facing the locked door", player.facing, Vector2i.UP)
	check("no warp through the locked door", world._is_warping, false)
