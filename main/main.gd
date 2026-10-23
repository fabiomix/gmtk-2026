extends Node
## Root of the game: holds the World and the UI and connects them,
## so World and UI don't need to know about each other.

@onready var _world: Node2D = $World
@onready var _hud: HUD = $HUD


func _ready() -> void:
	var player: Player = _world.get_node("Player")
	player.interaction_prompt_changed.connect(_hud.show_prompt)
	player.interacted.connect(_hud.show_message)
