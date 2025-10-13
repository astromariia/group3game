extends Node2D
class_name BoomerangOrb

@export var min_speed: float = 50.0           # speed when far from boss
@export var max_speed: float = 250.0           # speed when close to boss
@export var speed_curve_exponent: float = 1.5  # 1 = linear, >1 = snappier near boss
@export var max_range: float = 150.0           # turn-around distance
@export var catch_radius: float = 20.0         # despawn distance
@export var rotation_speed: float = 6.0        # radians/sec (spin rate)
@export var randomize_spin_direction: bool = true
@export var damage: int = 5

var _dir: Vector2 = Vector2.ZERO
var _home: Node2D = null
var _returning: bool = false
var _spin_dir: float = 1.0                     # clockwise or counterclockwise

func start(home: Node2D, dir: Vector2) -> void:
	_home = home
	_dir = dir.normalized()
	_returning = false
	_spin_dir = 1.0
	
func _physics_process(delta: float) -> void:
	if _home == null:
		queue_free()
		return

	var to_home: Vector2 = _home.global_position - global_position
	var dist: float = to_home.length()

	# speed depends only on distance from boss
	var v: float = _speed_for_dist(dist)
	var step_dir: Vector2 = to_home.normalized() if _returning else _dir
	global_position += step_dir * v * delta

	# continuous spin
	rotation += rotation_speed * _spin_dir * delta

	# flip to returning or despawn
	if not _returning and dist >= max_range:
		_returning = true
	elif _returning and dist <= catch_radius:
		queue_free()

func _speed_for_dist(dist: float) -> float:
	var t: float = clamp(1.0 - (dist / max_range), 0.0, 1.0)
	t = pow(t, speed_curve_exponent)
	return lerp(min_speed, max_speed, t)
	
func _on_body_entered(body: Node) -> void:
	if body and body.has_method("take_damage"):
		print(str(body))
		body.take_damage(damage)
