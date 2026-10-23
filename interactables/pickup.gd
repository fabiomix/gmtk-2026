@tool
class_name Pickup
extends StaticBody2D
## An item lying on a tile. Like in Pokémon it blocks the tile: face it and
## press interact to pick it up.
## @tool only to show the item icon in the editor; game logic never runs there.

@export var item: ItemData:
	set(value):
		item = value
		if is_node_ready():
			_update_sprite()

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_update_sprite()
	if Engine.is_editor_hint():
		return
	if item == null:
		push_error("Pickup '%s' has no item" % name)
		return
	# Already carried (e.g. kept from a previous run): don't duplicate it.
	if RunManager.has_item(item.id):
		queue_free()


## Interactable: text shown in the HUD when the player faces this tile.
func get_prompt() -> String:
	return "Pick up %s" % item.display_name


## Interactable: returns the message to show to the player.
func interact(_player: Player) -> String:
	RunManager.add_item(item)
	queue_free()
	return "Picked up: %s." % item.display_name


func _update_sprite() -> void:
	_sprite.texture = item.icon if item else null
