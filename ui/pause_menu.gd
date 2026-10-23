class_name PauseMenu
extends CanvasLayer
## Esc pauses the game (countdown included) and shows this menu; Esc again
## or Resume closes it. It opens only while the run is being played, so it
## can't interfere with the capture screen.
## Process mode is Always, otherwise it couldn't react while the game is paused.

@onready var _resume_button: Button = %ResumeButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	hide()
	_resume_button.pressed.connect(close)
	_quit_button.pressed.connect(get_tree().quit)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"pause"):
		return
	if visible:
		close()
	elif RunManager.is_playing() and not get_tree().paused:
		open()
	else:
		return
	get_viewport().set_input_as_handled()


func open() -> void:
	get_tree().paused = true
	show()
	_resume_button.grab_focus()  # so the menu works with the keyboard


func close() -> void:
	hide()
	get_tree().paused = false
