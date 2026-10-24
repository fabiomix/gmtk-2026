extends "res://tests/test_base.gd"
## Memories and journal: notes, lock notes, the combination lock, and
## persistence after a capture.
## Cell: scratches on the wall (4,0). Corridor: sign (3,0), evacuation plan
## (13,0). Laboratory: cabinet (6,1). Archive: filing cabinet (5,1) with
## combination, memo (7,1).

var run_manager: Node
var game_manager: Node
var journal: CanvasLayer
var journal_text: RichTextLabel
var last_message := ""


func run_tests() -> void:
	run_manager = root.get_node("RunManager")
	game_manager = root.get_node("GameManager")
	journal = main.get_node("Journal")
	journal_text = journal.get_node("%Text")
	player.interacted.connect(func(m: String) -> void: last_message = m)
	var hud: Node = main.get_node("HUD")
	var journal_label: Label = hud.get_node("%JournalLabel")
	var prompt_label: Label = hud.get_node("%PromptLabel")

	# The journal opens and closes, pausing the game.
	check("no memories at start", game_manager.discovered_memory_ids.is_empty(), true)
	await send_action(&"journal")
	check("J opens the journal", journal.visible, true)
	check("journal pauses the game", paused, true)
	check("empty journal", journal_text.get_parsed_text(), "Nothing yet.")
	await send_action(&"pause")
	check("Esc closes the journal", journal.visible, false)
	check("game resumed", paused, false)
	check("Esc didn't open the pause menu", main.get_node("PauseMenu").visible, false)

	# Scratches on the cell wall.
	await walk_to(CELL, Vector2i(4, 1))
	await face(Vector2i.UP)
	check("note prompt", prompt_label.text, "[E] Examine scratches")
	await press_interact()
	check("memory discovered", game_manager.has_memory(&"cell_scratches"), true)
	check("HUD announces it", journal_label.text, "Journal: Scratches on the wall")
	await press_interact()
	check("reading it again", last_message, "Already in your journal.")
	check("no duplicate memory", game_manager.discovered_memory_ids.size(), 1)
	await send_action(&"journal")
	check("journal shows the patrol time from the settings",
			journal_text.get_parsed_text().contains("1 MINUTE BETWEEN ROUNDS"), true)
	var scratches: Resource = load("res://data/memories/cell_scratches.tres")
	run_manager.run_duration = 120.0
	check("plural with 120 s", scratches.get_text().contains("2 MINUTES BETWEEN"), true)
	run_manager.run_duration = 90.0
	check("seconds with 90 s", scratches.get_text().contains("90 SECONDS BETWEEN"), true)
	run_manager.run_duration = 60.0
	await send_action(&"journal")
	check("J closes the journal too", journal.visible, false)

	# Corridor sign, then the lab cabinet examined without the screwdriver.
	await walk_to(CELL, Vector2i(5, 3))
	await walk_into_door(&"move_right")
	await walk_to(CORRIDOR, Vector2i(3, 1))
	await face(Vector2i.UP)
	await press_interact()
	check("sign read", game_manager.has_memory(&"corridor_sign"), true)
	await walk_to(CORRIDOR, Vector2i(13, 1))
	await face(Vector2i.UP)
	await press_interact()
	check("evacuation plan read in the corridor", game_manager.has_memory(&"evacuation_plan"), true)
	check("notes are announced", journal_label.text, "Journal: Evacuation plan")
	await walk_to(CORRIDOR, Vector2i(16, 2))
	await walk_into_door(&"move_right")
	await walk_to(LAB, Vector2i(6, 2))
	await face(Vector2i.UP)
	await press_interact()
	check("lock noted", game_manager.has_memory(&"lock_lab_cabinet"), true)
	check("only the contextual message is shown", last_message, "Locked. It needs: Screwdriver.")
	check("lock noted silently (no journal line)", journal_label.text.contains("Screwed cabinet"), false)
	await send_action(&"journal")
	var text := journal_text.get_parsed_text()
	check("sections in order: Notes before Locks", text.find("Notes") < text.find("Locks"), true)
	check("lock text in the journal", text.contains("Laboratory, cabinet: screwed shut."), true)
	await send_action(&"journal")

	# The filing cabinet needs the combination.
	await walk_to(LAB, Vector2i(1, 4))
	await walk_into_door(&"move_left")
	await walk_to(CORRIDOR, Vector2i(9, 2))
	await walk_into_door(&"move_up")
	await walk_to(ARCHIVE, Vector2i(5, 2))
	await face(Vector2i.UP)
	check("filing cabinet prompt without the code", prompt_label.text, "[E] Examine filing cabinet")
	await press_interact()
	check("it says what is missing", last_message, "Locked. You need the archive cabinet code.")
	check("combination lock noted", game_manager.has_memory(&"lock_archive_cabinet"), true)
	check("still closed", run_manager.has_item(&"lab_report"), false)
	# Learn the code directly (the guard log route is in test_route_investigation.gd).
	game_manager.discover(load("res://data/memories/archive_cabinet_code.tres"))
	await frames(2)
	check("filing cabinet prompt with the code", prompt_label.text, "[E] Open filing cabinet")
	await press_interact()
	check("opened with the code", last_message, "Opened. Found: Lab report.")

	# GLASSWING memo on the shelf.
	await walk_to(ARCHIVE, Vector2i(7, 2))
	await face(Vector2i.UP)
	await press_interact()
	check("memo read", game_manager.has_memory(&"glasswing_memo"), true)
	await send_action(&"journal")
	check("investigation section", journal_text.get_parsed_text().contains("Investigation"), true)
	await send_action(&"journal")

	# The scientist at the shelf (2,2): solid, and nothing to interact with.
	await walk_to(ARCHIVE, Vector2i(3, 2))
	await step(&"move_left")
	check("scientists can't be walked through", tile_of_player(ARCHIVE), Vector2i(3, 2))
	check("scientists have no prompt", prompt_label.text, "")

	# Memories survive a capture; the report (not kept) is lost.
	var known: int = game_manager.discovered_memory_ids.size()
	run_manager.time_left = 0.02
	await frames(5)
	await send_action(&"journal")
	check("journal doesn't open on the capture screen", journal.visible, false)
	main.get_node("CaptureScreen").get_node("%ConfirmButton").pressed.emit()
	await frames(3)
	refresh_world()
	check("memories kept after the capture", game_manager.discovered_memory_ids.size(), known)
	check("report not kept", run_manager.has_item(&"lab_report"), false)

	# The code is still known: the filing cabinet opens straight away.
	await walk_into_door(&"move_right")
	await walk_to(CORRIDOR, Vector2i(9, 2))
	await walk_into_door(&"move_up")
	await walk_to(ARCHIVE, Vector2i(5, 2))
	await face(Vector2i.UP)
	await press_interact()
	check("known code opens it in the next run", run_manager.has_item(&"lab_report"), true)
