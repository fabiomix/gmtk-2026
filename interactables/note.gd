@tool
class_name Note
extends Node2D
## Something to read: a note, a sign, scratches on a wall...
## Reading it adds its memory to the journal. It has no collision: place it
## on a solid tile (a wall or a piece of furniture) and read it facing that tile.
## @tool only to show the texture in the editor; game logic never runs there.

## Text of the HUD prompt, e.g. "Read sign", "Examine scratches".
@export var prompt := "Read note"
@export var texture: Texture2D:
	set(value):
		texture = value
		if is_node_ready():
			_sprite.texture = texture
@export var memory: MemoryData

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_sprite.texture = texture


## Interactable: text shown in the HUD when the player faces this tile.
func get_prompt() -> String:
	return prompt


## Interactable: a new memory is announced by the HUD (via GameManager),
## so there is nothing to say here unless it was already known.
func interact(_player: Player) -> String:
	if GameManager.discover(memory):
		return ""
	return "Already in your journal."
