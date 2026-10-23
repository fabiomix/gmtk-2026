class_name ItemData
extends Resource
## Definition of a physical item. One .tres per item in res://data/items/,
## named after its id (e.g. screwdriver.tres has id &"screwdriver").
## Game logic compares ids, never display names.

const ITEMS_DIR := "res://data/items/"

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D


## Loads the item definition from its id (file name convention above).
static func load_by_id(item_id: StringName) -> ItemData:
	var item: ItemData = load("%s%s.tres" % [ITEMS_DIR, item_id])
	if item == null or item.id != item_id:
		push_error("No item with id '%s' in %s" % [item_id, ITEMS_DIR])
	return item
