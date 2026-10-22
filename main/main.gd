extends Node
## Main scene (root of the game).
## Phase 1: only shows which input actions are pressed, to test the Input Map.
## The debug label will be replaced by World and UI in the next phases.

const ACTIONS: Array[StringName] = [
	&"move_up", &"move_down", &"move_left", &"move_right",
	&"interact", &"journal", &"pause",
]

@onready var debug_label: Label = $DebugLabel


func _ready() -> void:
	print("Main ready - Godot ", Engine.get_version_info().string)


func _process(_delta: float) -> void:
	var pressed := PackedStringArray()
	for action in ACTIONS:
		if Input.is_action_pressed(action):
			pressed.append(action)

	var pressed_text := "-" if pressed.is_empty() else ", ".join(pressed)
	debug_label.text = "Phase 1 OK\nPressed: " + pressed_text
