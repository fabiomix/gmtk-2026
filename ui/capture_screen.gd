class_name CaptureScreen
extends CanvasLayer
## Shown when the countdown reaches zero: the guards take the spy back to
## the cell (a capture, not a death). It lists the items being carried;
## Phase 6 will let the player choose which ones to keep.

@onready var _items_label: Label = %ItemsLabel


func _ready() -> void:
	hide()


func open() -> void:
	var names := PackedStringArray()
	for item in RunManager.inventory:
		names.append("- " + item.display_name)
	if names.is_empty():
		_items_label.text = "You were carrying nothing."
	else:
		_items_label.text = "You were carrying:\n" + "\n".join(names)
	show()
