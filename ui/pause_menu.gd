class_name PauseMenu
extends CanvasLayer
## Esc pauses the game (countdown included) and shows this menu; Esc again
## or Resume closes it. It opens only while the run is being played, so it
## can't interfere with the capture screen.
## New Game asks for confirmation in the same panel (Yes / No).
## Process mode is Always, otherwise it couldn't react while the game is paused.

signal new_game_requested

@onready var _menu_box: VBoxContainer = %MenuBox
@onready var _confirm_box: VBoxContainer = %ConfirmBox
@onready var _resume_button: Button = %ResumeButton
@onready var _new_game_button: Button = %NewGameButton
@onready var _quit_button: Button = %QuitButton
@onready var _yes_button: Button = %YesButton
@onready var _no_button: Button = %NoButton


func _ready() -> void:
	hide()
	_resume_button.pressed.connect(close)
	_new_game_button.pressed.connect(_show_confirm.bind(true))
	_quit_button.pressed.connect(get_tree().quit)
	# In a browser the game can't close itself: the player closes the tab.
	_quit_button.visible = not OS.has_feature("web")
	_yes_button.pressed.connect(_on_yes_pressed)
	_no_button.pressed.connect(_show_confirm.bind(false))


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
	_show_confirm(false)


func close() -> void:
	hide()
	get_tree().paused = false


## Switches between the menu and the "Start a new game?" question,
## moving the keyboard focus to the right button.
func _show_confirm(confirm: bool) -> void:
	_menu_box.visible = not confirm
	_confirm_box.visible = confirm
	if confirm:
		_no_button.grab_focus()
	else:
		_resume_button.grab_focus()


## The game stays paused: Main starts the new game (which shows the intro).
func _on_yes_pressed() -> void:
	hide()
	new_game_requested.emit()
