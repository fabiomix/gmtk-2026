class_name Player
extends CharacterBody2D
## Top-down spy: 8-direction movement, collides with walls (physics layer "world").

@export var speed: float = 120.0


func _physics_process(_delta: float) -> void:
	# get_vector() returns a normalized direction, so diagonals are not faster.
	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	velocity = direction * speed
	move_and_slide()
