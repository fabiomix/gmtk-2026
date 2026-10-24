extends SceneTree
## Base for headless tests: loads Main and offers input helpers.
## A test extends this file and overrides run_tests(). Run one with:
##   godot --headless --path . --script res://tests/test_movement.gd
## Exit code is 0 if all checks pass, 1 otherwise.
## Any error or warning printed during the test (script errors included)
## counts as a failure, so a test aborted by an error can't look "passed".
##
## Notes:
## - A --script is compiled before autoloads exist. In tests, don't use the
##   autoload names (RunManager...) or class types whose scripts use them
##   (HUD, Door, Pickup...): use root.get_node("RunManager") and Node instead.
## - Don't use `await` inside call arguments or `var x = await run_tests()`:
##   it corrupts the coroutine state. Store await results in a variable first.

## One tile takes 10 physics frames at 6 tiles/s: wait a bit more.
const STEP_FRAMES := 12

## Room origins in the World (see world/world.tscn).
const CELL := Vector2(0, 0)
const CORRIDOR := Vector2(1024, 0)
const ARCHIVE := Vector2(2048, 0)
const STORAGE := Vector2(3072, 0)
const LAB := Vector2(4096, 0)
const EXIT_ROOM := Vector2(5120, 0)

const DIRECTION_ACTIONS := {
	Vector2i.UP: &"move_up",
	Vector2i.DOWN: &"move_down",
	Vector2i.LEFT: &"move_left",
	Vector2i.RIGHT: &"move_right",
}

var main: Node
var world: Node2D
var player: Player
var failures := 0
var _errors := ErrorCounter.new()


## Counts errors and warnings printed by the engine while the test runs.
class ErrorCounter extends Logger:
	var count := 0

	func _log_error(_function: String, _file: String, _line: int, _code: String,
			_rationale: String, _editor_notify: bool, _error_type: int,
			_script_backtraces: Array[ScriptBacktrace]) -> void:
		count += 1


func _initialize() -> void:
	OS.add_logger(_errors)
	main = load("res://main/main.tscn").instantiate()
	root.add_child(main)
	await frames(2)  # Main creates the World in its _ready()
	refresh_world()
	await dismiss_intro()
	await run_tests()
	OS.remove_logger(_errors)
	if _errors.count > 0:
		failures += _errors.count
		print("[FAIL] %d error(s)/warning(s) logged during the test" % _errors.count)
	var result := "ALL PASSED" if failures == 0 else "%d FAILED" % failures
	print("RESULT: ", result)
	quit(1 if failures > 0 else 0)


## Override in each test.
func run_tests() -> void:
	pass


## A new game starts with the intro (game paused): press Continue.
func dismiss_intro() -> void:
	var intro: CanvasLayer = main.get_node("IntroScreen")
	if intro.visible:
		intro.get_node("%ContinueButton").pressed.emit()
		await frames(2)


## Names of the items shown in the HUD (one icon per item, name in the tooltip).
func hud_items() -> Array[String]:
	var names: Array[String] = []
	for icon in main.get_node("HUD").get_node("%InventoryIcons").get_children():
		names.append(icon.tooltip_text)
	return names


## Main creates a new World at every run: call this after a new run starts.
func refresh_world() -> void:
	world = main.get_node("World")
	player = world.get_node("Player")


func check(label: String, actual: Variant, expected: Variant) -> void:
	var ok: bool = actual == expected
	if not ok:
		failures += 1
	print("[%s] %s: %s (expected %s)" % ["OK" if ok else "FAIL", label, actual, expected])


func frames(n: int) -> void:
	for i in n:
		await physics_frame


func hold(action: StringName, n: int) -> void:
	Input.action_press(action)
	await frames(max(n, 1))
	Input.action_release(action)


## Taps a direction `count` times, waiting for each step to finish.
## If the tile is blocked, the spy only turns.
func step(action: StringName, count := 1) -> void:
	for i in count:
		await hold(action, 1)
		await frames(STEP_FRAMES)


func press_interact() -> void:
	await hold(&"interact", 1)
	await frames(2)


## Sends a real input event (menus use _input/_unhandled_input, which don't
## see Input.action_press). Events are delivered once per *process* frame,
## not per physics tick (at startup several ticks can run in one frame),
## so wait for process frames.
func send_action(action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame
	await process_frame


## Walks in a direction until a warp starts, then waits for it to end.
func walk_into_door(action: StringName, max_frames := 120) -> bool:
	Input.action_press(action)
	var warped := false
	for i in max_frames:
		await physics_frame
		if world._is_warping:
			warped = true
			break
	Input.action_release(action)
	while world._is_warping:
		await physics_frame
	await frames(2)
	return warped


## Walks like a real player (key held down) to a tile of the room at
## room_origin: first horizontally then vertically, or the opposite.
## The path must be free; fails the test if the player gets stuck.
func walk_to(room_origin: Vector2, tile: Vector2i, vertical_first := false) -> void:
	var here := tile_of_player(room_origin)
	var corner := Vector2i(here.x, tile.y) if vertical_first else Vector2i(tile.x, here.y)
	await _walk_line(room_origin, corner)
	await _walk_line(room_origin, tile)


func _walk_line(room_origin: Vector2, tile: Vector2i) -> void:
	var here := tile_of_player(room_origin)
	if here == tile:
		return
	var target := room_origin + Vector2(tile * Player.TILE_SIZE) + Vector2.ONE * (Player.TILE_SIZE / 2.0)
	var action: StringName = DIRECTION_ACTIONS[Vector2i((tile - here).sign())]
	Input.action_press(action)
	# Release during the last step, so the player stops exactly on the tile.
	var frames_left := 600
	while player._target_position != target and frames_left > 0:
		await physics_frame
		frames_left -= 1
	Input.action_release(action)
	while player._is_moving:
		await physics_frame
	check("walked to %s" % tile, tile_of_player(room_origin), tile)


## Turns towards a direction without moving (the tile there must be blocked).
func face(direction: Vector2i) -> void:
	await step(DIRECTION_ACTIONS[direction])


## Holds a direction until the run ends (used to walk into the Exit).
func walk_until_run_ends(action: StringName, run_manager: Node, max_frames := 600) -> void:
	Input.action_press(action)
	for i in max_frames:
		await physics_frame
		if not run_manager.is_playing():
			break
	Input.action_release(action)
	await frames(2)


## Tile coordinates of the player inside the room at room_origin.
func tile_of_player(room_origin: Vector2) -> Vector2i:
	return Vector2i(((player.global_position - room_origin) / Player.TILE_SIZE).floor())
