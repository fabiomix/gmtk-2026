extends Node2D
## The whole lab: rooms, doors and the player. Handles warps between doors.
## Must stay at position (0, 0): the player's tile grid uses global positions.

const FADE_TIME := 0.15

var _doors: Dictionary[StringName, Door] = {}
var _is_warping := false

@onready var _player: Player = $Player
@onready var _fade: ColorRect = $ScreenFade/Black


func _ready() -> void:
	for node in get_tree().get_nodes_in_group(&"doors"):
		# Only doors of this World (an old World may still exist while being freed).
		if not is_ancestor_of(node):
			continue
		var door := node as Door
		if _doors.has(door.door_id):
			push_error("Duplicate door_id '%s'" % door.door_id)
		_doors[door.door_id] = door
		door.player_entered.connect(_on_door_player_entered)


func _on_door_player_entered(door: Door) -> void:
	if _is_warping:
		return
	var target: Door = _doors.get(door.target_door_id)
	if target == null:
		push_warning("Door '%s' leads to unknown door '%s'" % [door.door_id, door.target_door_id])
		return

	_is_warping = true
	_player.set_physics_process(false)
	await _fade_to(1.0)
	_player.teleport(target.get_arrival_position(), target.inside_direction)
	await _fade_to(0.0)
	_player.set_physics_process(true)
	_is_warping = false


func _fade_to(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_fade, ^"modulate:a", alpha, FADE_TIME)
	await tween.finished
