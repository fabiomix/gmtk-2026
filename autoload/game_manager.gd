extends Node
## Autoload "GameManager": state of the whole game session (all the runs
## of one game). It survives captures; only a New Game will reset it.
## Temporary per-run state lives in RunManager instead.
## Stores ids, not resources, so it could be saved to disk in the future.

## How many physical items the spy can keep after a capture.
var keep_slots := 1
## Ids of the items kept at the last capture, given back at the next run.
var kept_item_ids: Array[StringName] = []


## Called after a capture with the ids chosen by the player.
func keep_items(ids: Array[StringName]) -> void:
	if ids.size() > keep_slots:
		push_error("Trying to keep %d items with %d slot(s)" % [ids.size(), keep_slots])
	kept_item_ids = ids.slice(0, keep_slots)
