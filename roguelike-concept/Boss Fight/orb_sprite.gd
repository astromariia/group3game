extends Node2D

@export var spin_speed: float = 8.0  # radians per second, tweak in editor

func _process(delta: float) -> void:
	rotation += spin_speed * delta
