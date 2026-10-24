extends Node
## Root of the game: creates the World of each run and connects it to the
## UI, so World and UI don't need to know about each other.
## Run loop: start run -> countdown -> capture -> choose items -> start run...

const WORLD_SCENE := preload("res://world/world.tscn")

var _world: Node2D

@onready var _hud: HUD = $HUD
@onready var _capture_screen: CaptureScreen = $CaptureScreen
@onready var _escape_screen: EscapeScreen = $EscapeScreen


func _ready() -> void:
	RunManager.captured.connect(_on_run_captured)
	RunManager.escaped.connect(_on_run_escaped)
	_capture_screen.items_chosen.connect(_on_capture_items_chosen)
	_start_run()


## Resets the run and replaces the World with a fresh copy: the spy is back
## in the cell, doors are locked again, items are back in their places.
func _start_run() -> void:
	# First the run state (with the kept items), then the new World:
	# its pickups check the inventory to avoid duplicating kept items.
	RunManager.start_run()
	if _world:
		remove_child(_world)
		_world.queue_free()
	_world = WORLD_SCENE.instantiate()
	add_child(_world)

	var player: Player = _world.get_node("Player")
	player.interaction_prompt_changed.connect(_hud.show_prompt)
	player.interacted.connect(_hud.show_message)
	_hud.show_prompt("")
	get_tree().paused = false


## The countdown reached zero: freeze the game (movement, interactions,
## warps) and show the capture screen.
func _on_run_captured() -> void:
	get_tree().paused = true
	_capture_screen.open()


## The spy reached the exit: freeze the game and show the escape screen.
func _on_run_escaped() -> void:
	get_tree().paused = true
	_escape_screen.open()


func _on_capture_items_chosen(ids: Array[StringName]) -> void:
	GameManager.keep_items(ids)
	_start_run()
