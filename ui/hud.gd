class_name HUD
extends CanvasLayer
## Heads-up display: run inventory icons (top left), countdown (top right),
## journal updates, short messages and interaction prompt (bottom).
## Inventory, countdown and journal updates come from the autoloads;
## prompt and messages are fed by Main (from the Player signals).
## Process mode is Always, so the countdown shows 0:00 even after the
## capture has paused the game.

const MESSAGE_TIME := 2.5
## Below this many seconds the countdown turns red.
const LOW_TIME := 20.0
const LOW_TIME_COLOR := Color(1, 0.35, 0.35)

@onready var _inventory_icons: HBoxContainer = %InventoryIcons
@onready var _timer_label: Label = %TimerLabel
@onready var _journal_label: Label = %JournalLabel
@onready var _message_label: Label = %MessageLabel
@onready var _prompt_label: Label = %PromptLabel
@onready var _message_timer: Timer = $MessageTimer
@onready var _journal_timer: Timer = $JournalTimer


func _ready() -> void:
	RunManager.inventory_changed.connect(_update_inventory)
	GameManager.memory_discovered.connect(_on_memory_discovered)
	_message_timer.timeout.connect(_on_message_timer_timeout)
	_journal_timer.timeout.connect(_on_journal_timer_timeout)
	_update_inventory()
	show_prompt("")
	_message_label.text = ""
	_journal_label.text = ""


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


## One icon per carried item, at its native 32 px (pixel art scales badly
## to non-integer sizes).
func _update_inventory() -> void:
	for icon in _inventory_icons.get_children():
		_inventory_icons.remove_child(icon)
		icon.queue_free()
	for item in RunManager.inventory:
		var icon := TextureRect.new()
		icon.texture = item.icon
		icon.tooltip_text = item.display_name
		_inventory_icons.add_child(icon)


func _on_message_timer_timeout() -> void:
	_message_label.text = ""


func _on_memory_discovered(memory: MemoryData) -> void:
	# Locks are noted silently: they come from an interaction that already
	# shows its own message ("Locked. It needs: ..."), one line is enough.
	if memory.category == MemoryData.Category.LOCK:
		return
	_journal_label.text = "Journal: %s" % memory.title
	_journal_timer.start(MESSAGE_TIME)


func _on_journal_timer_timeout() -> void:
	_journal_label.text = ""
