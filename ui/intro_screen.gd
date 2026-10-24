class_name IntroScreen
extends CanvasLayer
## The story so far, shown at the start of every new game (not after a
## capture). The game stays paused, so the countdown starts only when the
## player continues (E, Enter or Space).
## Process mode is Always, otherwise it couldn't react while the game is paused.

@onready var _continue_button: Button = %ContinueButton


func _ready() -> void:
	hide()
	_continue_button.pressed.connect(close)


## Enter/Space press the focused button; E is handled here.
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"interact"):
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	get_tree().paused = true
	show()
	_continue_button.grab_focus()


func close() -> void:
	hide()
	get_tree().paused = false
