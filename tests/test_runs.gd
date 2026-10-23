extends "res://tests/test_base.gd"
## Persistence between runs: choosing items to keep, slot limit, new World.
## Items are added straight to the inventory here (pickups are tested in
## test_items.gd) to keep the test short.

const CELL_START := Vector2(80, 112)

var run_manager: Node
var game_manager: Node
var capture_screen: CanvasLayer
var screwdriver: Resource
var badge: Resource


func run_tests() -> void:
	run_manager = root.get_node("RunManager")
	game_manager = root.get_node("GameManager")
	capture_screen = main.get_node("CaptureScreen")
	screwdriver = load("res://data/items/screwdriver.tres")
	badge = load("res://data/items/security_badge.tres")
	var inventory_label: Label = main.get_node("HUD").get_node("%InventoryLabel")

	check("1 slot by default", game_manager.keep_slots, 1)
	check("nothing kept at start", game_manager.kept_item_ids.is_empty(), true)

	# --- Run 1: carry both items, keep only the badge.
	run_manager.add_item(screwdriver)
	run_manager.add_item(badge)
	await capture()
	var boxes := checkboxes()
	check("one checkbox per carried item", boxes.size(), 2)
	check("hint mentions 1 item", capture_screen.get_node("%HintLabel").text.begins_with("You can hide 1 item "), true)
	var badge_box := box_for("Security badge")
	var screwdriver_box := box_for("Screwdriver")
	badge_box.button_pressed = true
	check("limit reached: other box disabled", screwdriver_box.disabled, true)
	check("ticked box stays enabled", badge_box.disabled, false)
	badge_box.button_pressed = false
	check("untick frees the slot again", screwdriver_box.disabled, false)
	badge_box.button_pressed = true
	var old_world := world
	await confirm()

	# --- Run 2: fresh World, badge kept, screwdriver confiscated.
	check("new run is playing", run_manager.is_playing(), true)
	check("game not paused", paused, false)
	check("capture screen hidden", capture_screen.visible, false)
	check("timer reset", run_manager.time_left > run_manager.run_duration - 1.0, true)
	check("World replaced", world != old_world, true)
	check("old World freed", is_instance_valid(old_world), false)
	check("player back in the cell", player.global_position, CELL_START)
	check("kept ids", game_manager.kept_item_ids, [&"security_badge"] as Array[StringName])
	check("badge in inventory", run_manager.has_item(&"security_badge"), true)
	check("screwdriver confiscated", run_manager.has_item(&"screwdriver"), false)
	check("HUD shows the kept item", inventory_label.text, "Items: Security badge")
	check("kept badge not duplicated in the World", has_pickup("Corridor", "SecurityBadge"), false)
	check("screwdriver back in its place", has_pickup("Cell", "Screwdriver"), true)
	check("corridor door locked again", world.get_node("Rooms/Corridor/Doors/CorridorNorth").locked, true)

	# --- Run 2 capture: the kept badge is listed again; keep nothing.
	await capture()
	check("kept item listed again", checkboxes().size(), 1)
	await confirm()
	check("nothing kept", run_manager.inventory.is_empty(), true)
	check("badge back in its place", has_pickup("Corridor", "SecurityBadge"), true)

	# --- 2 slots (configuration): both items can be kept.
	game_manager.keep_slots = 2
	run_manager.add_item(screwdriver)
	run_manager.add_item(badge)
	await capture()
	check("hint mentions 2 items", capture_screen.get_node("%HintLabel").text.begins_with("You can hide 2 items "), true)
	box_for("Screwdriver").button_pressed = true
	check("with 2 slots the second box is still enabled", box_for("Security badge").disabled, false)
	box_for("Security badge").button_pressed = true
	await confirm()
	check("both items kept", run_manager.inventory.size(), 2)
	check("no pickup duplicated", [has_pickup("Cell", "Screwdriver"), has_pickup("Corridor", "SecurityBadge")], [false, false])
	game_manager.keep_slots = 1

	# --- Capture in the middle of a warp: the new run starts clean.
	Input.action_press(&"move_right")
	while not world._is_warping:
		await physics_frame
	Input.action_release(&"move_right")
	run_manager.time_left = 0.02
	await frames(5)
	check("captured during the warp", capture_screen.visible, true)
	box_for("Screwdriver").button_pressed = true
	await confirm()
	check("fade transparent in the new World", world.get_node("ScreenFade/Black").modulate.a, 0.0)
	check("not warping in the new World", world._is_warping, false)
	check("player in the cell", player.global_position, CELL_START)
	await step(&"move_left")
	check("player can move again", player.global_position, CELL_START + Vector2(-32, 0))


## Forces the countdown to end and waits for the capture screen.
func capture() -> void:
	run_manager.time_left = 0.02
	await frames(5)


## Presses "Back to the cell" and waits for the new run.
func confirm() -> void:
	capture_screen.get_node("%ConfirmButton").pressed.emit()
	await frames(3)
	refresh_world()


func checkboxes() -> Array[Node]:
	return capture_screen.get_node("%ItemList").get_children()


func box_for(item_name: String) -> CheckBox:
	for box: CheckBox in checkboxes():
		if box.text == item_name:
			return box
	return null


func has_pickup(room: String, pickup: String) -> bool:
	return world.has_node("Rooms/%s/Items/%s" % [room, pickup])
