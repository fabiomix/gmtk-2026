class_name EscapeScreen
extends CanvasLayer
## Shown when the spy reaches the exit: the game is won.
## Phase 8 will add the investigation outcome and New Game.

@onready var _time_label: Label = %TimeLabel
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	hide()
	_quit_button.pressed.connect(get_tree().quit)


func open() -> void:
	_time_label.text = "Time left: %s" % HUD.format_time(RunManager.time_left)
	show()
	_quit_button.grab_focus()
