class_name EscapeScreen
extends CanvasLayer
## Shown when the spy reaches the exit: the game is won. Tells whether the
## investigation is complete (escaped carrying the lab report) and offers
## a new game.

signal new_game_requested

const REPORT_ID := &"lab_report"
const COMPLETE_TEXT := "You made it out with the GLASSWING report."
const INCOMPLETE_TEXT := "You made it out. The GLASSWING report is still down there."

@onready var _outcome_label: Label = %OutcomeLabel
@onready var _time_label: Label = %TimeLabel
@onready var _new_game_button: Button = %NewGameButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	hide()
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_quit_button.pressed.connect(get_tree().quit)


func open() -> void:
	var complete := RunManager.has_item(REPORT_ID)
	_outcome_label.text = COMPLETE_TEXT if complete else INCOMPLETE_TEXT
	_time_label.text = "Time left: %s" % HUD.format_time(RunManager.time_left)
	show()
	_new_game_button.grab_focus()


func _on_new_game_pressed() -> void:
	hide()
	new_game_requested.emit()
