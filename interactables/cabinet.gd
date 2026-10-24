@tool
class_name Cabinet
extends StaticBody2D
## A piece of furniture that holds an item (cabinet, filing cabinet...).
## It blocks its tile. Face it and interact: if the player has the
## required_item (or none is required) it opens and the contents go
## straight into the inventory. The required item is not consumed.
## It closes again at every new run (the World is rebuilt), except when the
## player already carries the contents (kept item): then it starts open and empty.
## @tool only to show the texture in the editor; game logic never runs there.

## Used in prompts and messages, e.g. "cabinet", "filing cabinet".
@export var display_name := "cabinet"
## 2 frames: closed | open.
@export var texture: Texture2D:
	set(value):
		texture = value
		if is_node_ready():
			_sprite.texture = texture
## Item needed to open it. Empty = it opens freely.
@export var required_item: ItemData
## Item inside. Empty = nothing inside.
@export var contents: ItemData

var _is_open := false

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_sprite.texture = texture
	if not Engine.is_editor_hint() and contents and RunManager.has_item(contents.id):
		_is_open = true
	_sprite.frame = 1 if _is_open else 0


## Interactable: open cabinets have nothing more to do.
func get_prompt() -> String:
	if _is_open:
		return ""
	if _can_open():
		return "Open %s" % display_name
	return "Examine %s" % display_name


## Interactable: returns the message to show to the player.
func interact(_player: Player) -> String:
	if not _can_open():
		return "Locked. It needs: %s." % required_item.display_name
	_is_open = true
	_sprite.frame = 1
	if contents == null:
		return "Opened. It's empty."
	RunManager.add_item(contents)
	return "Opened. Found: %s." % contents.display_name


func _can_open() -> bool:
	return required_item == null or RunManager.has_item(required_item.id)
