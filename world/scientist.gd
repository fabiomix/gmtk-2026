@tool
class_name Scientist
extends StaticBody2D
## A scientist busy at work. Decorative: solid (the spy can't walk through
## people) but not interactable, as there are no dialogues.
## Place scientists where they don't block a required passage.
## @tool only to show the facing direction in the editor.

## Where the scientist is looking, e.g. towards a desk.
@export var facing := Vector2i.DOWN:
	set(value):
		facing = value
		if is_node_ready():
			_update_sprite()

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_update_sprite()


func _update_sprite() -> void:
	# Same frame layout as the player: down | up | left | right.
	_sprite.frame = Player.FACING_FRAMES.get(facing, 0)
