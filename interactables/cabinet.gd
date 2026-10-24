@tool
class_name Cabinet
extends StaticBody2D
## A piece of furniture that holds an item (cabinet, filing cabinet...).
## It blocks its tile. Face it and interact: it opens if the player has the
## required_item and knows the required_memory (each only if set), and the
## contents go straight into the inventory. Nothing is consumed.
## Interacting while it's closed records its lock_memory in the journal
## (just a reminder: it's never needed to open it).
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
## Item needed to open it. Empty = no item needed.
@export var required_item: ItemData
## Memory needed to open it (e.g. a combination). Empty = no memory needed.
@export var required_memory: MemoryData
## Journal note about the lock, recorded when the player interacts with it.
@export var lock_memory: MemoryData
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
	if lock_memory:
		GameManager.discover(lock_memory)
	if required_item and not RunManager.has_item(required_item.id):
		return "Locked. It needs: %s." % required_item.display_name
	if required_memory and not GameManager.has_memory(required_memory.id):
		return "Locked. You need the %s." % required_memory.title.to_lower()
	_is_open = true
	_sprite.frame = 1
	if contents == null:
		return "Opened. It's empty."
	RunManager.add_item(contents)
	return "Opened. Found: %s." % contents.display_name


func _can_open() -> bool:
	var has_item := required_item == null or RunManager.has_item(required_item.id)
	var knows := required_memory == null or GameManager.has_memory(required_memory.id)
	return has_item and knows
