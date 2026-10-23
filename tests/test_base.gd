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


## Sends a real input event (menus use _unhandled_input, which doesn't see
## Input.action_press).
func send_action(action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await frames(2)


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


## Tile coordinates of the player inside the room at room_origin.
func tile_of_player(room_origin: Vector2) -> Vector2i:
	return Vector2i(((player.global_position - room_origin) / Player.TILE_SIZE).floor())
