extends "res://tests/test_base.gd"
## Pickups, inventory, HUD and a door that requires an item.
## Cell: screwdriver at (4,1). Corridor (1024,0): badge at (16,2),
## corridor_north at (9,0) needs the badge and leads to Archive (2048,0).

const CORRIDOR := Vector2(1024, 0)
const ARCHIVE := Vector2(2048, 0)

var last_message := ""
## Autoload names are not known when a --script is compiled: get the node instead.
var run_manager: Node


func run_tests() -> void:
	run_manager = root.get_node("RunManager")
	player.interacted.connect(func(m: String) -> void: last_message = m)
	var hud: Node = main.get_node("HUD")
	var inventory_label: Label = hud.get_node("%InventoryLabel")
	var prompt_label: Label = hud.get_node("%PromptLabel")
	check("HUD starts empty", inventory_label.text, "Items: -")

	# Screwdriver in the cell: it blocks its tile, face it and interact.
	await step(&"move_right", 2)
	await step(&"move_up", 2)
	check("blocked by the screwdriver", tile_of_player(Vector2.ZERO), Vector2i(4, 2))
	check("prompt shown", prompt_label.text, "[E] Pick up Screwdriver")
	await press_interact()
	check("screwdriver in inventory", run_manager.has_item(&"screwdriver"), true)
	check("pickup message", last_message, "Picked up: Screwdriver.")
	check("HUD inventory", inventory_label.text, "Items: Screwdriver")
	check("prompt cleared", prompt_label.text, "")
	await step(&"move_up")
	check("tile free after pickup", tile_of_player(Vector2.ZERO), Vector2i(4, 1))

	# Locked door without the badge.
	await step(&"move_down", 2)
	await walk_into_door(&"move_right")
	await step(&"move_right", 8)
	await step(&"move_up", 2)
	check("facing the locked door", tile_of_player(CORRIDOR), Vector2i(9, 1))
	check("door prompt without badge", prompt_label.text, "[E] Examine door")
	await press_interact()
	check("door says what it needs", last_message, "Locked. It needs: Security badge.")
	var door: Node = world.get_node("Rooms/Corridor/Doors/CorridorNorth")
	check("door still locked", door.locked, true)

	# Get the badge at the end of the corridor.
	await step(&"move_down")
	await step(&"move_right", 7)
	check("blocked by the badge", tile_of_player(CORRIDOR), Vector2i(15, 2))
	await press_interact()
	check("badge in inventory", run_manager.has_item(&"security_badge"), true)
	check("HUD inventory with 2 items", inventory_label.text, "Items: Screwdriver, Security badge")

	# Unlock the door and go through.
	await step(&"move_left", 6)
	await step(&"move_up", 2)
	check("door prompt with badge", prompt_label.text, "[E] Unlock with Security badge")
	await press_interact()
	check("unlock message", last_message, "Unlocked with Security badge.")
	check("door unlocked", door.locked, false)
	check("badge not consumed", run_manager.has_item(&"security_badge"), true)
	await frames(2)
	var warped := await walk_into_door(&"move_up")
	check("warp into the archive", warped, true)
	check("arrived in the archive", tile_of_player(ARCHIVE), Vector2i(5, 5))

	# No duplicates.
	run_manager.add_item(load("res://data/items/screwdriver.tres"))
	check("no duplicate items", run_manager.inventory.size(), 2)
