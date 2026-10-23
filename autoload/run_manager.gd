extends Node
## Autoload "RunManager": state of the current run (a single escape attempt).
## Everything here is temporary and will be reset at every new run.
## Persistent state (memories, kept items) will live in GameManager instead.

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
