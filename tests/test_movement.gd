extends "res://tests/test_base.gd"
## Grid movement in the Cell (origin 0,0). Player starts at tile (2,3).
## Cell: 7x6 tiles, walls on the border, bed (crates) at (1,1) and (2,1).


func run_tests() -> void:
	check("start on tile (2,3)", tile_of_player(Vector2.ZERO), Vector2i(2, 3))
	check("start on tile center", player.global_position, Vector2(80, 112))

	await step(&"move_left")
	check("tap = one full step left", player.global_position, Vector2(48, 112))

	await hold(&"move_left", 30)
	await frames(STEP_FRAMES)
	check("stopped at the left wall", player.global_position, Vector2(48, 112))
	check("facing left", player.facing, Vector2i.LEFT)
	check("sprite frame left", player.get_node("Sprite2D").frame, 2)

	await hold(&"move_up", 30)
	await frames(STEP_FRAMES)
	check("stopped below the bed", tile_of_player(Vector2.ZERO), Vector2i(1, 2))

	# Continuous walk: 6 tiles/s -> 3 tiles in 30 frames, from (1,2) to (4,2), no hitches.
	await hold(&"move_right", 30)
	check("30 frames = exactly 3 tiles", snappedf(player.global_position.x, 0.01), 48.0 + 96.0)
	await frames(STEP_FRAMES)
	check("ends on a tile center", fmod(player.global_position.x - 16.0, 32.0), 0.0)

	# Two keys: going down, also press right -> keep going down (no zig-zag).
	await step(&"move_left", 2)
	var column_x := player.global_position.x
	Input.action_press(&"move_down")
	await frames(3)
	Input.action_press(&"move_right")
	await frames(8)
	Input.action_release(&"move_down")
	Input.action_release(&"move_right")
	await frames(STEP_FRAMES)
	check("two keys keep the current direction", player.global_position.x, column_x)
