class_name Player
extends CharacterBody2D
## Top-down spy with Pokémon-style grid movement: 4 directions, one tile per step.
## A step is blocked if the target tile contains something on the "world"
## physics layer (walls, crates, pickups and locked doors).
## Rooms must be placed at multiples of TILE_SIZE so tile centers line up.
##
## Interactions: the spy interacts with the tile in front (see facing).
## An "interactable" is any node that:
##   - is in the group "interactables" and sits on a tile center;
##   - has get_prompt() -> String  (HUD text; "" = nothing to do right now);
##   - has interact(player: Player) -> String  (message shown to the player).

signal interaction_prompt_changed(text: String)
signal interacted(message: String)

const TILE_SIZE := 32

## Input action -> direction. Order matters only when two keys are pressed
## and none of them is the current facing direction.
const DIRECTIONS := {
	&"move_up": Vector2i.UP,
	&"move_down": Vector2i.DOWN,
	&"move_left": Vector2i.LEFT,
	&"move_right": Vector2i.RIGHT,
}

## Sprite frame for each facing direction (player.png: down | up | left | right).
const FACING_FRAMES := {
	Vector2i.DOWN: 0,
	Vector2i.UP: 1,
	Vector2i.LEFT: 2,
	Vector2i.RIGHT: 3,
}

## Walking speed in tiles per second.
@export var tiles_per_second: float = 6.0

## Direction the spy is looking at. Interactions use the tile in front.
var facing := Vector2i.DOWN

var _is_moving := false
var _target_position := Vector2.ZERO
var _prompt := ""

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	# Make sure we start exactly on a tile center, even if placed loosely in the editor.
	position = _snap_to_tile_center(position)
	_target_position = position
	_sprite.frame = FACING_FRAMES[facing]


func _physics_process(delta: float) -> void:
	if not _is_moving:
		if Input.is_action_just_pressed(&"interact"):
			_interact()
		_try_start_step()
	if _is_moving:
		_move(delta)
	_update_prompt()


## Instantly moves the spy to the tile at new_position (used by door warps).
func teleport(new_position: Vector2, new_facing: Vector2i) -> void:
	global_position = _snap_to_tile_center(new_position)
	_target_position = position
	_is_moving = false
	facing = new_facing
	_sprite.frame = FACING_FRAMES[facing]


## Moves towards the target tile center.
func _move(delta: float) -> void:
	var distance := tiles_per_second * TILE_SIZE * delta
	var remaining := position.distance_to(_target_position)
	if distance < remaining:
		position = position.move_toward(_target_position, distance)
		return

	# Arrived on the tile. If a direction is still held, start the next step
	# in the same frame and use the leftover distance, so walking is smooth.
	position = _target_position
	_is_moving = false
	_try_start_step()
	if _is_moving:
		position = position.move_toward(_target_position, distance - remaining)


func _interact() -> void:
	var target = _get_interactable_in_front()
	if target == null:
		return
	var message: String = target.interact(self)
	if message != "":
		interacted.emit(message)


## Updates the HUD prompt only when the text changes.
func _update_prompt() -> void:
	var text := ""
	if not _is_moving:
		var target = _get_interactable_in_front()
		if target != null:
			text = target.get_prompt()
	if text != _prompt:
		_prompt = text
		interaction_prompt_changed.emit(_prompt)


## Returns the interactable on the tile in front of the spy, or null.
## Untyped on purpose: interactables have different base types (Pickup, Door...).
func _get_interactable_in_front():
	var front := global_position + Vector2(facing * TILE_SIZE)
	for node in get_tree().get_nodes_in_group(&"interactables"):
		if node.is_queued_for_deletion():
			continue
		if node.global_position.distance_to(front) < 1.0 and node.get_prompt() != "":
			return node
	return null


## Reads the input and, if the tile in that direction is free, starts a step.
## The spy turns towards the pressed direction even if the step is blocked.
func _try_start_step() -> void:
	var direction := _read_direction()
	if direction == Vector2i.ZERO:
		return

	facing = direction
	_sprite.frame = FACING_FRAMES[facing]

	var target := position + Vector2(direction * TILE_SIZE)
	if _is_tile_free(target):
		_target_position = target
		_is_moving = true


func _read_direction() -> Vector2i:
	var held: Array[Vector2i] = []
	for action in DIRECTIONS:
		if Input.is_action_pressed(action):
			held.append(DIRECTIONS[action])
	if held.is_empty():
		return Vector2i.ZERO
	# Keep going the same way while that key is held, to avoid zig-zagging
	# when a second key is pressed.
	if facing in held:
		return facing
	return held[0]


func _is_tile_free(point: Vector2) -> bool:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = point
	query.collision_mask = collision_mask
	return get_world_2d().direct_space_state.intersect_point(query, 1).is_empty()


func _snap_to_tile_center(point: Vector2) -> Vector2:
	return (point / TILE_SIZE).floor() * TILE_SIZE + Vector2.ONE * (TILE_SIZE / 2.0)
