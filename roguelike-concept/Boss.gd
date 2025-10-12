extends CharacterBody2D

@onready var pointer : Node2D = $POINTY
@onready var player : Node2D = %elf
@onready var _animated_sprite = $AnimatedSprite2D
@onready var attackCooldown: Timer = $ShootyCooldown

@export var speed: float = 0.5
@export var facingDir: String = "left"
@export var mud: PackedScene

# Orbit config
@export var num_circles: int = 12
@export var radius: float = 150.0                         # actual live radius used for positioning
@export var target_radius: float = 150.0                  # change this on the fly
@export var radius_move_speed: float = 200.0              # px/sec to move radius toward target
@export var rotation_speed: float = 1.0                   # radians/sec
@export var circle_size: float = 20.0
@export var circle_color: Color = Color.CYAN

# --- NEW: Auto-grow/shrink controls ---
@export var auto_pulse: bool = true                       # toggle this on/off in the inspector
@export var min_radius: float = 100.0
@export var max_radius: float = 240.0
@export var pulse_period_sec: float = 3.0                 # full grow+shrink cycle duration

var circles: Array = []
var angles: Array = []

var HP := 10
var currentHealth := HP

func facing():
	var playerPos = player.global_position
	var selfPos = global_position
	if playerPos.x > selfPos.x:
		_animated_sprite.flip_h = false
		_animated_sprite.play("spit")
		facingDir = "left"
	else:
		_animated_sprite.flip_h = true
		_animated_sprite.play("spit")
		facingDir = "right"
	pointer.pointAt(self, facingDir)

func _ready():
	attackCooldown.one_shot = true
	attackCooldown.autostart = false

	# Spawn orbiting "circles" (ColorRect controls)
	for i in range(num_circles):
		var circle := ColorRect.new()
		circle.color = circle_color
		circle.size = Vector2(circle_size, circle_size)
		circle.set_anchors_preset(Control.PRESET_CENTER)
		circle.pivot_offset = circle.size * 0.5
		add_child(circle)
		circles.append(circle)
		angles.append(TAU / num_circles * i)

	_update_positions(0.0)

	# --- NEW: Call your helper to make the radius breathe (grow/shrink) forever ---
	if auto_pulse:
		var base := 0.5 * (min_radius + max_radius)
		var amp  := 0.5 * (max_radius - min_radius)
		# This calls YOUR function below; it keeps setting `target_radius` smoothly.
		pulse_radius(base, amp, pulse_period_sec)

func take_damage(amount: int):
	currentHealth -= amount
	if currentHealth <= 0:
		currentHealth = 0
		print("boss is dead")
		queue_free()

func _update_positions(delta: float):
	var n := circles.size()
	for i in range(n):
		angles[i] += rotation_speed * delta
		var x := radius * cos(angles[i])
		var y := radius * sin(angles[i])
		circles[i].position = Vector2(x, y)

func _physics_process(delta: float):
	facing()

	# Smoothly move actual radius toward the target radius
	if !is_equal_approx(radius, target_radius):
		radius = move_toward(radius, target_radius, radius_move_speed * delta)

	_update_positions(delta)

# --- Convenience API for the fight script/AI ---

## Instantly set the orbit radius (no smoothing)
func set_orbit_radius(new_radius: float) -> void:
	radius = max(new_radius, 0.0)
	target_radius = radius

## Smoothly tween the *property* to a new target radius over a duration
func tween_to_radius(new_target: float, duration: float = 0.6, trans := Tween.TRANS_SINE, ease := Tween.EASE_IN_OUT) -> void:
	var tween := create_tween()
	tween.tween_property(self, "target_radius", max(new_target, 0.0), duration).set_trans(trans).set_ease(ease)

## Pulse the radius around a base value (good for phases)
func pulse_radius(base: float, amplitude: float, period_sec: float) -> void:
	var tween := create_tween().set_loops() # infinite loop
	tween.tween_callback(func():
		var t := Time.get_ticks_msec() / 1000.0
		target_radius = max(base + amplitude * sin(TAU * t / period_sec), 0.0)
	).set_delay(0.016)  # ~60 Hz updates
