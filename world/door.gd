class_name Door
extends Area2D
## A door tile placed in a wall gap. When the player steps on it, the door
## emits player_entered and the World warps the player to the target door.
## A locked door blocks its tile like a wall (Blocker on the "world" layer);
## if it has a required_item, the player can unlock it by interacting with it.
## Unlocking lasts only for the current run (the World is rebuilt every run).

signal player_entered(door: Door)

## Unique id in the whole lab, e.g. &"cell_east".
@export var door_id: StringName
## Id of the door where the player arrives. Empty = leads nowhere (yet).
@export var target_door_id: StringName
## Direction from the door towards the inside of its room.
## The player arrives on that tile, facing that way.
@export var inside_direction := Vector2i.DOWN
@export var locked := false:
	set(value):
		locked = value
		if is_node_ready():
			_update_locked_state()
## Item that unlocks this door. Empty = it can't be unlocked by the player.
## The item is not consumed.
@export var required_item: ItemData
## Journal note about the lock, recorded when the player interacts with the
## locked door (just a reminder: it's never needed to unlock it).
@export var lock_memory: MemoryData

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _blocker_shape: CollisionShape2D = $Blocker/CollisionShape2D


func _ready() -> void:
	_update_locked_state()
	body_entered.connect(_on_body_entered)


## Global position of the tile in front of the door, inside the room.
func get_arrival_position() -> Vector2:
	return global_position + Vector2(inside_direction * Player.TILE_SIZE)


## Interactable: only locked doors can be interacted with.
func get_prompt() -> String:
	if not locked:
		return ""
	if required_item and RunManager.has_item(required_item.id):
		return "Unlock with %s" % required_item.display_name
	return "Examine door"


## Interactable: returns the message to show to the player.
func interact(_player: Player) -> String:
	if lock_memory:
		GameManager.discover(lock_memory)
	if required_item == null:
		return "Locked. No way to open it from this side."
	if not RunManager.has_item(required_item.id):
		return "Locked. It needs: %s." % required_item.display_name
	locked = false
	return "Unlocked with %s." % required_item.display_name


func _update_locked_state() -> void:
	_sprite.frame = 1 if locked else 0
	# Deferred: collision shapes must not change in the middle of a physics step.
	_blocker_shape.set_deferred(&"disabled", not locked)


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not locked:
		player_entered.emit(self)
