class_name HUD
extends CanvasLayer
## Heads-up display: run inventory (top left), countdown (top right),
## interaction prompt and short messages (bottom).
## Inventory and countdown read RunManager by themselves; prompt and
## messages are fed by Main (from the Player signals).
## Process mode is Always, so the countdown shows 0:00 even after the
## capture has paused the game.

const MESSAGE_TIME := 2.5
## Below this many seconds the countdown turns red.
const LOW_TIME := 20.0
const LOW_TIME_COLOR := Color(1, 0.35, 0.35)

@onready var _inventory_label: Label = %InventoryLabel
@onready var _timer_label: Label = %TimerLabel
@onready var _message_label: Label = %MessageLabel
@onready var _prompt_label: Label = %PromptLabel
@onready var _message_timer: Timer = $MessageTimer


func _ready() -> void:
	RunManager.inventory_changed.connect(_update_inventory)
	_message_timer.timeout.connect(_on_message_timer_timeout)
	_update_inventory()
	show_prompt("")
	_message_label.text = ""


func _process(_delta: float) -> void:
	_timer_label.text = format_time(RunManager.time_left)
	_timer_label.modulate = LOW_TIME_COLOR if RunManager.time_left <= LOW_TIME else Color.WHITE


func show_prompt(text: String) -> void:
	_prompt_label.text = "" if text == "" else "[E] " + text


func show_message(text: String) -> void:
	_message_label.text = text
	_message_timer.start(MESSAGE_TIME)


## "m:ss", rounding up: shows 2:00 at the start and 0:00 only at zero.
static func format_time(seconds: float) -> String:
	var total := ceili(seconds)
	return "%d:%02d" % [floori(total / 60.0), total % 60]


func _update_inventory() -> void:
	var names := PackedStringArray()
	for item in RunManager.inventory:
		names.append(item.display_name)
	_inventory_label.text = "Items: " + ("-" if names.is_empty() else ", ".join(names))


func _on_message_timer_timeout() -> void:
	_message_label.text = ""
