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
## "{patrol_minutes}" is replaced with the run duration in minutes.
@export_multiline var text: String
@export var category := Category.NOTE


## The text with its placeholders filled in, so it always matches the settings.
func get_text() -> String:
	# One decimal at most, and "2" instead of "2.0".
	var minutes := String.num(RunManager.run_duration / 60.0, 1).trim_suffix(".0")
	return text.format({"patrol_minutes": minutes})


## Loads the memory definition from its id (file name convention above).
static func load_by_id(memory_id: StringName) -> MemoryData:
	var memory: MemoryData = load("%s%s.tres" % [MEMORIES_DIR, memory_id])
	if memory == null or memory.id != memory_id:
		push_error("No memory with id '%s' in %s" % [memory_id, MEMORIES_DIR])
	return memory
