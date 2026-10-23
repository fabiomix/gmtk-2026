class_name CaptureScreen
extends CanvasLayer
## Shown when the countdown reaches zero: the guards take the spy back to
## the cell (a capture, not a death). The player ticks the items to hide
## from the guards, up to GameManager.keep_slots, and confirms.
## The rest is confiscated (it will be back in its usual place next run).

## Emitted on confirm, with the ids of the chosen items.
signal items_chosen(ids: Array[StringName])

## Checkbox -> id of the item it represents.
var _checkboxes: Dictionary[CheckBox, StringName] = {}

@onready var _hint_label: Label = %HintLabel
@onready var _item_list: VBoxContainer = %ItemList
@onready var _confirm_button: Button = %ConfirmButton


func _ready() -> void:
	hide()
	_confirm_button.pressed.connect(_on_confirm_pressed)


func open() -> void:
	for box in _checkboxes:
		_item_list.remove_child(box)
		box.queue_free()
	_checkboxes.clear()

	for item in RunManager.inventory:
		var box := CheckBox.new()
		box.text = item.display_name
		box.icon = item.icon
		box.toggled.connect(_on_checkbox_toggled.unbind(1))
		_item_list.add_child(box)
		_checkboxes[box] = item.id

	var slots := GameManager.keep_slots
	if _checkboxes.is_empty():
		_hint_label.text = "You were carrying nothing."
	else:
		_hint_label.text = "You can hide %d %s from the guards.\nEverything else will be confiscated." \
				% [slots, "item" if slots == 1 else "items"]
	_update_limit()
	show()
	# Keyboard: arrows move, Space/Enter ticks a box or confirms.
	if _checkboxes.is_empty():
		_confirm_button.grab_focus()
	else:
		_checkboxes.keys()[0].grab_focus()


func _selected_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for box in _checkboxes:
		if box.button_pressed:
			ids.append(_checkboxes[box])
	return ids


## When the limit is reached, the unticked boxes can't be ticked anymore.
func _update_limit() -> void:
	var limit_reached := _selected_ids().size() >= GameManager.keep_slots
	for box in _checkboxes:
		box.disabled = limit_reached and not box.button_pressed


func _on_checkbox_toggled() -> void:
	_update_limit()


func _on_confirm_pressed() -> void:
	var ids := _selected_ids()
	hide()
	items_chosen.emit(ids)
