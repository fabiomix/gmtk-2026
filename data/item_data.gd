class_name ItemData
extends Resource
## Definition of a physical item. One .tres per item in res://data/items/,
## named after its id (e.g. screwdriver.tres has id &"screwdriver").
## Game logic compares ids, never display names.

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
