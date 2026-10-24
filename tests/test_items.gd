extends "res://tests/test_base.gd"
## Pickups, cabinets, HUD and a door that requires an item.
## Storage: screwdriver at (8,6). Laboratory: cabinet at (6,1) needs the
## screwdriver and holds the badge; door lab_east at (13,4) needs the badge.
## (Notes, memories and the combination lock are in test_journal.gd.)

var last_message := ""
## Autoload names are not known when a --script is compiled: get the node instead.
var run_manager: Node


func run_tests() -> void:
	run_manager = root.get_node("RunManager")
	player.interacted.connect(func(m: String) -> void: last_message = m)
	var hud: Node = main.get_node("HUD")
	var prompt_label: Label = hud.get_node("%PromptLabel")
	check("HUD starts empty", hud_items(), [] as Array[String])

	# Laboratory first, without the screwdriver.
	await walk_into_door(&"move_right")
	await walk_to(CORRIDOR, Vector2i(16, 2))
	await walk_into_door(&"move_right")
	await walk_to(LAB, Vector2i(6, 2))
	await face(Vector2i.UP)
	check("cabinet prompt without screwdriver", prompt_label.text, "[E] Examine cabinet")
	await press_interact()
	check("cabinet says what it needs", last_message, "Locked. It needs: Screwdriver.")
	var cabinet: Node = world.get_node("Rooms/Laboratory/Items/Cabinet")
	check("cabinet still closed", cabinet.get_node("Sprite2D").frame, 0)

	await walk_to(LAB, Vector2i(12, 4))
	await face(Vector2i.RIGHT)
	check("door prompt without badge", prompt_label.text, "[E] Examine door")
	await press_interact()
	check("door says what it needs", last_message, "Locked. It needs: Security badge.")

	# Screwdriver in the storage: it blocks its tile, face it and interact.
	await walk_to(LAB, Vector2i(1, 4))
	await walk_into_door(&"move_left")
	await walk_to(CORRIDOR, Vector2i(9, 2))
	await walk_into_door(&"move_down")
	await walk_to(STORAGE, Vector2i(7, 6), true)
	await face(Vector2i.RIGHT)
	check("pickup prompt", prompt_label.text, "[E] Pick up Screwdriver")
	await press_interact()
	check("pickup message", last_message, "Picked up: Screwdriver.")
	check("HUD shows the icon", hud_items(), ["Screwdriver"] as Array[String])
	check("pickup removed", world.has_node("Rooms/Storage/Items/Screwdriver"), false)
	await step(&"move_right")
	check("tile free after pickup", tile_of_player(STORAGE), Vector2i(8, 6))

	# Back to the laboratory: open the cabinet, unlock the door.
	await walk_to(STORAGE, Vector2i(5, 6))
	await walk_into_door(&"move_up")
	await walk_to(CORRIDOR, Vector2i(9, 2))
	await walk_into_door(&"move_right")
	await walk_to(LAB, Vector2i(6, 2))
	await face(Vector2i.UP)
	check("cabinet prompt with screwdriver", prompt_label.text, "[E] Open cabinet")
	await press_interact()
	check("cabinet message", last_message, "Opened. Found: Security badge.")
	check("cabinet open", cabinet.get_node("Sprite2D").frame, 1)
	check("badge in inventory", run_manager.has_item(&"security_badge"), true)
	check("screwdriver not consumed", run_manager.has_item(&"screwdriver"), true)
	check("open cabinet has no prompt", prompt_label.text, "")
	await press_interact()
	check("open cabinet gives nothing more", run_manager.inventory.size(), 2)

	await walk_to(LAB, Vector2i(12, 4))
	await face(Vector2i.RIGHT)
	check("door prompt with badge", prompt_label.text, "[E] Unlock with Security badge")
	await press_interact()
	check("unlock message", last_message, "Unlocked with Security badge.")
	check("door unlocked", world.get_node("Rooms/Laboratory/Doors/LabEast").locked, false)
	var warped := await walk_into_door(&"move_right")
	check("warp into the exit room", warped, true)
	check("arrived in the exit room", tile_of_player(EXIT_ROOM), Vector2i(1, 3))
	check("HUD shows 2 icons", hud_items(), ["Screwdriver", "Security badge"] as Array[String])

	# No duplicates.
	run_manager.add_item(load("res://data/items/screwdriver.tres"))
	check("no duplicate items", run_manager.inventory.size(), 2)
