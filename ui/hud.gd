class_name HUD
extends CanvasLayer
## Heads-up display: run inventory (top), interaction prompt and short
## messages (bottom). Inventory updates by itself via RunManager;
## prompt and messages are fed by Main (from the Player signals).

const MESSAGE_TIME := 2.5

@onready var _inventory_label: Label = %InventoryLabel
@onready var _message_label: Label = %MessageLabel
@onready var _prompt_label: Label = %PromptLabel
@onready var _message_timer: Timer = $MessageTimer


func _ready() -> void:
	RunManager.inventory_changed.connect(_update_inventory)
	_message_timer.timeout.connect(_on_message_timer_timeout)
	_update_inventory()
	show_prompt("")
	_message_label.text = ""


func show_prompt(text: String) -> void:
	_prompt_label.text = "" if text == "" else "[E] " + text


func show_message(text: String) -> void:
	_message_label.text = text
	_message_timer.start(MESSAGE_TIME)


func _update_inventory() -> void:
	var names := PackedStringArray()
	for item in RunManager.inventory:
		names.append(item.display_name)
	_inventory_label.text = "Items: " + ("-" if names.is_empty() else ", ".join(names))


func _on_message_timer_timeout() -> void:
	_message_label.text = ""
