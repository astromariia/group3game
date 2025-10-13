extends CharacterBody2D

# -----------------------------
# Scene Nodes & External Scripts
# -----------------------------
@onready var pointer: Node2D       = $POINTY
@onready var player: Node2D        = %elf
@onready var _animated_sprite      = $AnimatedSprite2D
@onready var attackCooldown: Timer = $ShootyCooldown
@onready var wander_timer: Timer   = Timer.new()   # created, added in config

const OrbitHazard := preload("res://Boss Fight/orbit_hazard.gd")

# -----------------------------
# Boss & Attack
# -----------------------------
@export var speed: float = 0.5
@export var facingDir: String = "left"
@export var mud: PackedScene
var HP: int = 50
var currentHealth: int = HP

# -----------------------------
# Orbit Config (ring behavior)
# -----------------------------
@export var num_circles: int = 6
@export var radius: float = 150.0
@export var target_radius: float = 150.0
@export var radius_move_speed: float = 200.0
@export var rotation_speed: float = 0.5

# Orbiting projectile scene (editable in editor)
@export var orbit_orb_scene: PackedScene = preload("res://Boss Fight/OrbProjectile.tscn")

# Hazard overrides (applied to BOTH orbiting & boomerang projectiles)
@export var orb_damage: int = 1
@export var orb_collision_layer: int = 2
@export var orb_collision_mask: int = 1

# Optional: override circle radius from code (keeps editor shape if false)
@export var override_hit_radius_from_code: bool = false
@export var orb_hit_shape_radius: float = 16.0

# Optional debug
@export var debug_log_hazard_values: bool = false

# Pulsing
@export var min_radius: float = 50.0
@export var max_radius: float = 200.0
@export var pulse_period_sec: float = 5.0
@export var auto_pulse: bool = true

# -----------------------------
# Wander (boss drift)
# -----------------------------
@export var wander_enabled: bool = true
@export var wander_radius: float = 50.0
@export var wander_speed: float = 30.0
@export var wander_pause_sec: float = 5.0
@export var arrive_epsilon: float = 4.0

var wander_origin: Vector2
var wander_target: Vector2
var is_waiting: bool = false

# -----------------------------
# Orbit State
# -----------------------------
var circles: Array[Node2D] = []
var angles:  Array[float]  = []

# -----------------------------
# Boomerang Burst
# -----------------------------
const BoomerangScene: PackedScene = preload("res://Boss Fight/BoomerangOrb.tscn")

@export var boomerang_cooldown_sec: float = 1.0
@export var peak_margin_px: float = 2.0
var _last_target_radius: float = 0.0
var _boomerang_armed: bool = true
@onready var _boomerang_cooldown: Timer = Timer.new()

# =============================
# Lifecycle
# =============================
func _ready() -> void:
	initialize()

func _physics_process(delta: float) -> void:
	_update_facing()
	_update_orbit_radius(delta)
	_handle_wander(delta)
	move_and_slide()
	_update_orbit_positions(delta)

# =============================
# One-call initialization
# =============================
func initialize() -> void:
	_configure_attack_cooldown()
	_configure_wander_system()
	_build_orbit_ring(num_circles)
	_configure_boomerang_system()
	_start_pulse_if_enabled()

# ----- Configure pieces -----
func _configure_attack_cooldown() -> void:
	attackCooldown.one_shot = true
	attackCooldown.autostart = false

func _configure_wander_system() -> void:
	add_child(wander_timer)
	wander_timer.one_shot = true
	wander_timer.timeout.connect(_on_wander_pause_done)
	wander_origin = global_position
	_pick_new_wander_target()

func _configure_boomerang_system() -> void:
	add_child(_boomerang_cooldown)
	_boomerang_cooldown.one_shot = true
	# typed lambda avoids Variant inference warnings
	_boomerang_cooldown.timeout.connect(func() -> void: _boomerang_armed = true)
	_last_target_radius = target_radius

func _start_pulse_if_enabled() -> void:
	if not auto_pulse:
		return
	var base := 0.5 * (min_radius + max_radius)
	var amp  := 0.5 * (max_radius - min_radius)
	_start_pulse(base, amp, pulse_period_sec)

# =============================
# Facing / Animation
# =============================
func _update_facing() -> void:
	var playerPos := player.global_position
	var look_right := playerPos.x > global_position.x
	_animated_sprite.flip_h = not look_right
	_animated_sprite.play("spit")
	facingDir = "left" if look_right else "right"
	pointer.pointAt(self, facingDir)

# =============================
# Orbit: Build & Update
# =============================
func _build_orbit_ring(count: int) -> void:
	_clear_orbs()
	for i in range(count):
		var orb_holder := Node2D.new()      # holder we position on the circle
		add_child(orb_holder)

		var core := orbit_orb_scene.instantiate()
		orb_holder.add_child(core)

		# Ensure damage/layers/mask (and optional shape) are consistent
		_configure_orb_core(core)

		circles.append(orb_holder)
		angles.append(TAU * i / max(1, count))

	_update_orbit_positions(0.0)

func _clear_orbs() -> void:
	for c in circles:
		if is_instance_valid(c):
			c.queue_free()
	circles.clear()
	angles.clear()

func _update_orbit_positions(delta: float) -> void:
	for i in range(circles.size()):
		angles[i] += rotation_speed * delta
		circles[i].position = Vector2(
			radius * cos(angles[i]),
			radius * sin(angles[i])
		)

# =============================
# Radius Control / Pulse
# =============================
func _update_orbit_radius(delta: float) -> void:
	if not is_equal_approx(radius, target_radius):
		radius = move_toward(radius, target_radius, radius_move_speed * delta)

func set_orbit_radius(new_radius: float) -> void:
	radius = max(new_radius, 0.0)
	target_radius = radius

func tween_to_radius(new_target: float, duration: float = 0.6, trans := Tween.TRANS_SINE, ease := Tween.EASE_IN_OUT) -> void:
	var t := create_tween()
	t.tween_property(self, "target_radius", max(new_target, 0.0), duration).set_trans(trans).set_ease(ease)

func _start_pulse(base: float, amplitude: float, period_sec: float) -> void:
	var tw := create_tween().set_loops()
	tw.tween_callback(func() -> void:
		var tsec := Time.get_ticks_msec() / 1000.0
		var new_target: float = max(base + amplitude * sin(TAU * tsec / max(0.001, period_sec)), 0.0)
		_on_pulse_sample(new_target)
	).set_delay(0.016)

func _on_pulse_sample(new_target: float) -> void:
	var rising := new_target > _last_target_radius
	target_radius = new_target

	# Rising into the top band near max -> fire burst once
	if rising and _boomerang_armed and (max_radius - new_target) <= peak_margin_px:
		_fire_boomerangs()
		_boomerang_armed = false
		_boomerang_cooldown.start(boomerang_cooldown_sec)

	# Hysteresis re-arm (when clearly out of peak band)
	if (max_radius - new_target) > (peak_margin_px * 4.0) and not _boomerang_cooldown.time_left > 0.0:
		_boomerang_armed = true

	_last_target_radius = new_target

# =============================
# Boomerang Spawn
# =============================
func _fire_boomerangs() -> void:
	var dirs := [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
	for d in dirs:
		_spawn_boomerang(d)

func _spawn_boomerang(dir: Vector2) -> void:
	var b := BoomerangScene.instantiate()
	get_tree().current_scene.add_child(b)
	b.global_position = global_position

	# Apply the same hazard config used by the orbiters
	_configure_orb_core(b)

	# Start its motion
	if b.has_method("start"):
		b.call("start", self, dir)

# =============================
# Wander (Boss Drift)
# =============================
func _handle_wander(_delta: float) -> void:
	if not wander_enabled or is_waiting:
		velocity = Vector2.ZERO
		return
	var to_target := wander_target - global_position
	if to_target.length() <= arrive_epsilon:
		velocity = Vector2.ZERO
		is_waiting = true
		wander_timer.start(wander_pause_sec)
	else:
		velocity = to_target.normalized() * wander_speed

func _pick_new_wander_target() -> void:
	var ang := randf() * TAU
	var r   := sqrt(randf()) * wander_radius
	wander_target = wander_origin + Vector2(cos(ang), sin(ang)) * r
	is_waiting = false

func _on_wander_pause_done() -> void:
	is_waiting = false
	_pick_new_wander_target()

# =============================
# Combat / Health
# =============================
func take_damage(amount: int) -> void:
	currentHealth -= amount
	if currentHealth <= 0:
		currentHealth = 0
		_on_death()

func _on_death() -> void:
	print("boss is dead")
	queue_free()

# =============================
# Shared Hazard Config + Helpers
# =============================
func _configure_orb_core(root: Node) -> void:
	# Find the Area2D that actually runs OrbitHazard.gd
	var area := _find_area2d_with_orbit_hazard(root)
	if area == null:
		push_warning("No Area2D with OrbitHazard.gd found under %s" % root.name)
		return

	# Collision config
	area.collision_layer = orb_collision_layer
	area.collision_mask  = orb_collision_mask
	area.monitoring = true
	area.monitorable = true

	# Explicitly override damage on the hazard script instance
	if "damage" in area:
		area.damage = orb_damage
	else:
		area.set("damage", orb_damage)

	# Optional radius override (only if the scene uses a CircleShape2D)
	if override_hit_radius_from_code:
		var shape := _find_collision_shape(area)
		if shape and (shape.shape is CircleShape2D):
			(shape.shape as CircleShape2D).radius = orb_hit_shape_radius

	

func _find_area2d_with_orbit_hazard(node: Node) -> Area2D:
	var q: Array = [node]
	while q.size() > 0:
		var n: Node = q.pop_front()
		if n is Area2D and n.get_script() == OrbitHazard:
			return n
		for c in n.get_children():
			q.append(c)
	return null

func _find_collision_shape(area: Area2D) -> CollisionShape2D:
	for c in area.get_children():
		if c is CollisionShape2D:
			return c
	return null
