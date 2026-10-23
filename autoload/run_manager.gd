extends Node
## Autoload "RunManager": state of the current run (a single escape attempt).
## Everything here is temporary: start_run() resets it at every new run.
## Persistent state (kept items, later memories) lives in GameManager.

signal inventory_changed
## Emitted exactly once per run, when the countdown reaches zero.
signal captured

enum State { PLAYING, CAPTURED }

## Length of a run in seconds.
var run_duration := 120.0
## Seconds left before the guards arrive.
var time_left := run_duration
var state := State.PLAYING
## Items carried during this run. Never contains the same item twice.
var inventory: Array[ItemData] = []


## Resets the run state. The items kept at the last capture start in the
## inventory. Must be called before the World of the new run is created,
## so its pickups can see those items and not appear twice.
func start_run() -> void:
	time_left = run_duration
	state = State.PLAYING
	inventory.clear()
	for id in GameManager.kept_item_ids:
		inventory.append(ItemData.load_by_id(id))
	inventory_changed.emit()


## Counts down on the physics clock (fixed 60 ticks/s, like the player's
## movement). It stops by itself while the game is paused.
func _physics_process(delta: float) -> void:
	if state != State.PLAYING:
		return
	time_left = maxf(time_left - delta, 0.0)
	if time_left == 0.0:
		# Change the state first: from now on this code can't run again,
		# so the capture happens only once.
		state = State.CAPTURED
		captured.emit()


func is_playing() -> bool:
	return state == State.PLAYING


func add_item(item: ItemData) -> void:
	if has_item(item.id):
		return
	inventory.append(item)
	inventory_changed.emit()


func has_item(id: StringName) -> bool:
	for item in inventory:
		if item.id == id:
			return true
	return false
