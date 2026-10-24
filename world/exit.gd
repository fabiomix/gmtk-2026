class_name Exit
extends Area2D
## The way out of the lab, placed in a wall gap like a door.
## Stepping on it ends the run with a successful escape.


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		RunManager.escape()
