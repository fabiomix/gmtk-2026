extends "res://tests/test_base.gd"
## The optimal route that also completes the investigation, in one run:
## main route up to the exit room, archive key, back to the archive
## (filing cabinet: lab report), back to the exit. Measures the time.

var run_manager: Node


func run_tests() -> void:
	run_manager = root.get_node("RunManager")
	var start_tick := Engine.get_physics_frames()

	# Main route up to the exit room (see test_route_escape.gd).
	await walk_into_door(&"move_right")
	await walk_to(CORRIDOR, Vector2i(9, 2))
	await walk_into_door(&"move_down")
	await walk_to(STORAGE, Vector2i(7, 6), true)
	await face(Vector2i.RIGHT)
	await press_interact()                                 # screwdriver
	await walk_to(STORAGE, Vector2i(5, 6))
	await walk_into_door(&"move_up")
	await walk_to(CORRIDOR, Vector2i(9, 2))
	await walk_into_door(&"move_right")
	await walk_to(LAB, Vector2i(6, 2))
	await face(Vector2i.UP)
	await press_interact()                                 # cabinet: badge
	await walk_to(LAB, Vector2i(12, 4))
	await face(Vector2i.RIGHT)
	await press_interact()                                 # badge door
	await walk_into_door(&"move_right")                    # -> exit room (1,3)

	# Archive key on the guard's desk.
	await walk_to(EXIT_ROOM, Vector2i(4, 2))
	await face(Vector2i.UP)
	await press_interact()
	check("archive key collected", run_manager.has_item(&"archive_key"), true)

	# Back to the archive.
	await walk_to(EXIT_ROOM, Vector2i(1, 3))
	await walk_into_door(&"move_left")                     # -> laboratory (12,4)
	await walk_to(LAB, Vector2i(1, 4))
	await walk_into_door(&"move_left")                     # -> corridor (16,2)
	await walk_to(CORRIDOR, Vector2i(9, 2))
	await walk_into_door(&"move_up")                       # -> archive (5,5)
	await walk_to(ARCHIVE, Vector2i(5, 2))
	await face(Vector2i.UP)
	await press_interact()                                 # filing cabinet: report
	check("lab report collected", run_manager.has_item(&"lab_report"), true)

	# And out.
	await walk_into_door(&"move_down")                     # -> corridor (9,1)
	await walk_to(CORRIDOR, Vector2i(9, 2))
	await walk_into_door(&"move_right")                    # -> laboratory (1,4)
	await walk_into_door(&"move_right")                    # -> exit room (1,3)
	await walk_until_run_ends(&"move_right", run_manager)

	var seconds := (Engine.get_physics_frames() - start_tick) / 60.0
	print("Optimal escape + investigation route: %.1f s (run lasts %d s)" % [seconds, run_manager.run_duration])
	check("escaped", run_manager.state, run_manager.State.ESCAPED)
	check("escaped carrying the lab report", run_manager.has_item(&"lab_report"), true)
	check("within the time limit", seconds < run_manager.run_duration, true)
