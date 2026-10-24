extends "res://tests/test_base.gd"
## Intro, escape outcome (investigation complete or not), New Game from the
## escape screen and from the pause menu.
## Escapes are triggered directly here: the routes are in test_route_*.gd.

var run_manager: Node
var game_manager: Node
var intro: CanvasLayer
var escape_screen: CanvasLayer
var pause_menu: CanvasLayer


func run_tests() -> void:
	run_manager = root.get_node("RunManager")
	game_manager = root.get_node("GameManager")
	intro = main.get_node("IntroScreen")
	escape_screen = main.get_node("EscapeScreen")
	pause_menu = main.get_node("PauseMenu")

	# test_base already closed the intro of the first game: check it worked.
	check("intro closed", intro.visible, false)
	check("game running after the intro", paused, false)

	# --- Escape carrying the report: investigation complete.
	run_manager.add_item(load("res://data/items/lab_report.tres"))
	game_manager.discover(load("res://data/memories/corridor_sign.tres"))
	run_manager.escape()
	await frames(2)
	check("escape screen visible", escape_screen.visible, true)
	check("investigation complete",
			escape_screen.get_node("%OutcomeLabel").text, "You made it out with the GLASSWING report.")

	# --- New Game from the escape screen.
	escape_screen.get_node("%NewGameButton").pressed.emit()
	await frames(3)
	refresh_world()
	check("escape screen hidden", escape_screen.visible, false)
	check("intro shown again", intro.visible, true)
	check("paused during the intro", paused, true)
	check("memories forgotten", game_manager.discovered_memory_ids.is_empty(), true)
	check("inventory empty", run_manager.inventory.is_empty(), true)
	check("new run playing", run_manager.is_playing(), true)
	var time_at_intro: float = run_manager.time_left
	await frames(30)
	check("countdown waits for the intro", run_manager.time_left, time_at_intro)
	await send_action(&"interact")
	check("E closes the intro", intro.visible, false)
	check("game running", paused, false)
	check("player in the cell", tile_of_player(CELL), Vector2i(2, 3))

	# --- Escape without the report: investigation incomplete.
	run_manager.escape()
	await frames(2)
	check("investigation incomplete", escape_screen.get_node("%OutcomeLabel").text,
			"You made it out. The GLASSWING report is still down there.")
	escape_screen.get_node("%NewGameButton").pressed.emit()
	await frames(3)
	await dismiss_intro()
	refresh_world()

	# --- New Game from the pause menu, with confirmation.
	run_manager.add_item(load("res://data/items/screwdriver.tres"))
	game_manager.discover(load("res://data/memories/corridor_sign.tres"))
	game_manager.keep_items([&"screwdriver"] as Array[StringName])
	await send_action(&"pause")
	check("pause menu open", pause_menu.visible, true)
	pause_menu.get_node("%NewGameButton").pressed.emit()
	await frames(2)
	check("confirmation shown", pause_menu.get_node("%ConfirmBox").visible, true)
	check("menu buttons hidden", pause_menu.get_node("%MenuBox").visible, false)
	pause_menu.get_node("%NoButton").pressed.emit()
	await frames(2)
	check("No goes back to the menu", pause_menu.get_node("%MenuBox").visible, true)
	check("still paused", paused, true)
	check("nothing reset after No", game_manager.has_memory(&"corridor_sign"), true)
	pause_menu.get_node("%NewGameButton").pressed.emit()
	await frames(2)
	pause_menu.get_node("%YesButton").pressed.emit()
	await frames(3)
	refresh_world()
	check("pause menu hidden", pause_menu.visible, false)
	check("intro shown for the new game", intro.visible, true)
	check("memories forgotten", game_manager.discovered_memory_ids.is_empty(), true)
	check("kept items forgotten", game_manager.kept_item_ids.is_empty(), true)
	check("inventory empty", run_manager.inventory.is_empty(), true)
	await dismiss_intro()
	await send_action(&"pause")
	check("pause menu opens on the menu, not the question", pause_menu.get_node("%MenuBox").visible, true)
	await send_action(&"pause")
