extends Node
## Autoload "GameManager": state of the whole game session (all the runs
## of one game). It survives captures; only a New Game will reset it.
## Temporary per-run state lives in RunManager instead.
## Stores ids, not resources, so it could be saved to disk in the future.

## Emitted the first time a memory is discovered in this game.
signal memory_discovered(memory: MemoryData)

## How many physical items the spy can keep after a capture.
var keep_slots := 1
## Ids of the items kept at the last capture, given back at the next run.
var kept_item_ids: Array[StringName] = []
## Ids of the discovered memories, in discovery order.
var discovered_memory_ids: Array[StringName] = []


## Called after a capture with the ids chosen by the player.
func keep_items(ids: Array[StringName]) -> void:
	if ids.size() > keep_slots:
		push_error("Trying to keep %d items with %d slot(s)" % [ids.size(), keep_slots])
	kept_item_ids = ids.slice(0, keep_slots)


## Adds a memory to the journal. Returns false if it was already known.
func discover(memory: MemoryData) -> bool:
	if has_memory(memory.id):
		return false
	discovered_memory_ids.append(memory.id)
	memory_discovered.emit(memory)
	return true


func has_memory(id: StringName) -> bool:
	return id in discovered_memory_ids


## The discovered memories, in discovery order.
func get_memories() -> Array[MemoryData]:
	var memories: Array[MemoryData] = []
	for id in discovered_memory_ids:
		memories.append(MemoryData.load_by_id(id))
	return memories
