extends "res://tests/test_base.gd"
## Countdown, pause menu and capture.

const TICK := 1.0 / 60.0

var run_manager: Node
var captured_count := 0


func run_tests() -> void:
	run_manager = root.get_node("RunManager")
	run_manager.captured.connect(func() -> void: captured_count += 1)
	var timer_label: Label = main.get_node("HUD").get_node("%TimerLabel")
	var pause_menu: CanvasLayer = main.get_node("PauseMenu")
	var capture_screen: CanvasLayer = main.get_node("CaptureScreen")

	# Keys: P pauses too (Esc leaves fullscreen in browsers), J and Tab open the journal.
	check("pause keys", action_keys(&"pause"), [KEY_ESCAPE, KEY_P])
	check("journal keys", action_keys(&"journal"), [KEY_J, KEY_TAB])

	# Countdown runs in real time: 60 physics ticks = 1 second.
	check("run lasts 60 s", run_manager.run_duration, 60.0)
	var t0: float = run_manager.time_left
	await frames(60)
	check("60 ticks = 1 s", snappedf(t0 - run_manager.time_left, 0.001), 1.0)
	check("HUD shows the countdown", timer_label.text, "0:59")

	# The countdown keeps running during a warp.
	t0 = run_manager.time_left
	var tick0 := Engine.get_physics_frames()
	await walk_into_door(&"move_right")
	var expected := (Engine.get_physics_frames() - tick0) * TICK
	check("timer runs during the warp", absf((t0 - run_manager.time_left) - expected) < TICK * 2, true)

	# Pause: Esc stops everything, countdown included.
	await send_action(&"pause")
	check("Esc pauses the game", paused, true)
	check("pause menu visible", pause_menu.visible, true)
	t0 = run_manager.time_left
	var pos: Vector2 = player.global_position
	await hold(&"move_right", 30)
	await frames(30)
	check("countdown frozen in pause", run_manager.time_left, t0)
	check("player frozen in pause", player.global_position, pos)
	await send_action(&"pause")
	check("Esc again resumes", paused, false)
	check("pause menu hidden", pause_menu.visible, false)

	# Resume button works too.
	await send_action(&"pause")
	pause_menu.get_node("%ResumeButton").pressed.emit()
	await frames(2)
	check("Resume button resumes", paused, false)

	# Capture: bring the countdown close to zero.
	run_manager.time_left = 0.5
	await frames(29)
	check("not captured yet", captured_count, 0)
	await frames(60)
	check("captured exactly once", captured_count, 1)
	check("run state is CAPTURED", run_manager.is_playing(), false)
	check("game paused on capture", paused, true)
	check("capture screen visible", capture_screen.visible, true)
	check("capture screen lists nothing carried",
			capture_screen.get_node("%HintLabel").text, "You were carrying nothing.")
	check("HUD shows 0:00", timer_label.text, "0:00")

	pos = player.global_position
	await hold(&"move_left", 30)
	await frames(30)
	check("player frozen after capture", player.global_position, pos)
	await send_action(&"pause")
	check("Esc doesn't open the pause menu on the capture screen", pause_menu.visible, false)
	check("still paused", paused, true)
	check("still captured only once", captured_count, 1)


func action_keys(action: StringName) -> Array:
	var keys := []
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			keys.append(event.physical_keycode)
	return keys
