extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@export var speed = 1
@onready var weapon: Node2D = $bow
@export var maxHealth = 30
@onready var currentHealth: int
signal healthChanged
@export var facingDir = "right"

signal weapon_changed(new_weapon_name: String)

func _ready():
	add_to_group("player")
	currentHealth = maxHealth
	emit_signal("weapon_changed", get_current_weapon_name())


	
func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * 1.5
	if input_direction.x < 0:
		_animated_sprite.flip_h = true
		_animated_sprite.play("elf_m_run")
		facingDir = "left"
	elif input_direction.x > 0 :
		_animated_sprite.flip_h = false
		facingDir = "right"
		_animated_sprite.play("elf_m_run")	
	elif input_direction.y < 0 :
		facingDir = "up"
		_animated_sprite.play("elf_m_run")
	elif input_direction.y > 0 :
		facingDir = "down"
		_animated_sprite.play("elf_m_run")
	else:
		_animated_sprite.play("elf_m_idle")
	weapon.pointAt(self, facingDir)	



func _physics_process(_delta):
	get_input()
	var collision := move_and_collide(velocity)
	if collision != null:
		var body := collision.get_collider()
		if body.is_in_group("enemy"):
			_animated_sprite.play("elf_hit")

func take_damage(amount: int):
	currentHealth -= amount
	if currentHealth < 0:
		currentHealth = 0
		print("Player is dead")
		death()
	healthChanged.emit()

func death():
	get_tree().change_scene_to_file("res://die_screen.tscn")
	
func get_current_weapon_name() -> String:
	if weapon.name == "bow":
		return "Bow"
	else:
		return ""

func equip_weapon(new_weapon: Node2D):
	weapon = new_weapon
	emit_signal("weapon_changed", get_current_weapon_name())
