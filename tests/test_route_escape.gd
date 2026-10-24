extends "res://tests/test_base.gd"
## The optimal escape route, played like a player who knows the map:
## cell -> storage (screwdriver) -> laboratory (cabinet: badge, badge door)
## -> exit room -> exit. Measures the time, for balancing.

var run_manager: Node


func run_tests() -> void:
	run_manager = root.get_node("RunManager")
	var start_tick := Engine.get_physics_frames()

	await walk_into_door(&"move_right")                    # -> corridor (1,2)
	await walk_to(CORRIDOR, Vector2i(9, 2))
	await walk_into_door(&"move_down")                     # -> storage (5,1)
	await walk_to(STORAGE, Vector2i(7, 6), true)
	await face(Vector2i.RIGHT)
	await press_interact()                                 # screwdriver
	await walk_to(STORAGE, Vector2i(5, 6))
	await walk_into_door(&"move_up")                       # -> corridor (9,3)
	await walk_to(CORRIDOR, Vector2i(9, 2))
	await walk_into_door(&"move_right")                    # -> laboratory (1,4)
	await walk_to(LAB, Vector2i(6, 2))
	await face(Vector2i.UP)
	await press_interact()                                 # cabinet: badge
	await walk_to(LAB, Vector2i(12, 4))
	await face(Vector2i.RIGHT)
	await press_interact()                                 # badge door
	await walk_into_door(&"move_right")                    # -> exit room (1,3)
	check("badge collected", run_manager.has_item(&"security_badge"), true)
	await walk_until_run_ends(&"move_right", run_manager)  # -> exit (9,3)

	var seconds := (Engine.get_physics_frames() - start_tick) / 60.0
	print("Optimal escape route: %.1f s (run lasts %d s)" % [seconds, run_manager.run_duration])
	check("escaped", run_manager.state, run_manager.State.ESCAPED)
	check("escape well within the time limit", seconds < run_manager.run_duration, true)
	check("game paused", paused, true)
	var escape_screen: Node = main.get_node("EscapeScreen")
	check("escape screen visible", escape_screen.visible, true)
	check("escape screen shows the time left",
			escape_screen.get_node("%TimeLabel").text.begins_with("Time left: "), true)

	# After the escape the countdown is over: no capture can happen.
	var captured := [false]
	run_manager.captured.connect(func() -> void: captured[0] = true)
	run_manager.time_left = 0.02
	await frames(10)
	check("no capture after the escape", captured[0], false)
	check("still escaped", run_manager.state, run_manager.State.ESCAPED)
