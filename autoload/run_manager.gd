extends Node
## Autoload "RunManager": state of the current run (a single escape attempt).
## Everything here is temporary and will be reset at every new run.
## Persistent state (memories, kept items) will live in GameManager instead.

signal inventory_changed

## Items carried during this run. Never contains the same item twice.
var inventory: Array[ItemData] = []


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
