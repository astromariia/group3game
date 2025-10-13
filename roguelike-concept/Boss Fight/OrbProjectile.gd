# res://Boss Fight/OrbProjectile.gd
extends Node2D
class_name OrbProjectile

# Spin config (same pattern as BoomerangOrb)
@export var rotation_speed: float = 6.0        # radians/sec
@export var randomize_spin_direction: bool = true
@export var default_spin_direction: float = 1.0  # used if not randomized; +1 or -1

# Optional: spin a specific child (e.g., only the Sprite2D), leave empty to spin the whole node
@export var spin_target: NodePath = NodePath("")  # e.g., NodePath("Sprite2D")

var _spin_dir: float = 1.0

func _ready() -> void:
	_spin_dir = (-1.0 if randf() < 0.5 else 1.0) if randomize_spin_direction else signf(default_spin_direction)
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	var target := _get_spin_target()
	if target:
		target.rotation += rotation_speed * _spin_dir * delta

func _get_spin_target() -> Node2D:
	if spin_target.is_empty():
		return self
	return get_node_or_null(spin_target) as Node2D
