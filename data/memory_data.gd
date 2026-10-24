class_name MemoryData
extends Resource
## A piece of information the spy discovered. It stays in the journal for
## the whole game (all runs) and never takes an item slot.
## One .tres per memory in res://data/memories/, named after its id.

const MEMORIES_DIR := "res://data/memories/"

## Journal sections, in display order.
enum Category { NOTE, LOCK, INVESTIGATION }

@export var id: StringName
## Short: shown in the HUD when discovered and as heading in the journal.
@export var title: String
## Full text, shown only in the journal.
## "{patrol}" is replaced with the run duration in capitals, with the right
## unit and plural: "1 MINUTE", "2 MINUTES", "90 SECONDS".
@export_multiline var text: String
@export var category := Category.NOTE


## The text with its placeholders filled in, so it always matches the settings.
func get_text() -> String:
	return text.format({"patrol": patrol_interval()})


## The run duration in words, e.g. "1 MINUTE", "2 MINUTES", "90 SECONDS".
static func patrol_interval() -> String:
	var seconds := roundi(RunManager.run_duration)
	if seconds % 60 != 0:
		return "%d SECONDS" % seconds
	var minutes := floori(seconds / 60.0)
	return "%d MINUTE%s" % [minutes, "" if minutes == 1 else "S"]


## Loads the memory definition from its id (file name convention above).
static func load_by_id(memory_id: StringName) -> MemoryData:
	var memory: MemoryData = load("%s%s.tres" % [MEMORIES_DIR, memory_id])
	if memory == null or memory.id != memory_id:
		push_error("No memory with id '%s' in %s" % [memory_id, MEMORIES_DIR])
	return memory
