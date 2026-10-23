extends Node
## Root of the game: holds the World and the UI and connects them,
## so World and UI don't need to know about each other.

@onready var _world: Node2D = $World
@onready var _hud: HUD = $HUD
@onready var _capture_screen: CaptureScreen = $CaptureScreen


func _ready() -> void:
	var player: Player = _world.get_node("Player")
	player.interaction_prompt_changed.connect(_hud.show_prompt)
	player.interacted.connect(_hud.show_message)
	RunManager.captured.connect(_on_run_captured)


## The countdown reached zero: freeze the game (movement, interactions,
## warps) and show the capture screen.
func _on_run_captured() -> void:
	get_tree().paused = true
	_capture_screen.open()
