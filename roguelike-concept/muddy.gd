extends CharacterBody2D
@onready var player : Node2D = %elf
@onready var _animated_sprite = $AnimatedSprite2D
@export var speed = 0.5
@export var muddy : PackedScene
@onready var attackCooldown: Timer = $ShootyCooldown

var HP = 10
var currentHealth = HP

#time in between attacks, in seconds
var attackSpeed = 1
#damage in HP
var damage = 1


func facing():
	var playerPos = player.global_position
	var selfPos = global_position
	var facing = selfPos-playerPos
	if playerPos.x > selfPos.x:
		_animated_sprite.flip_h = false
		_animated_sprite.play("spit")
	else:
		_animated_sprite.flip_h = true
		_animated_sprite.play("spit")

func _ready():
	attackCooldown.one_shot = true
	attackCooldown.autostart = false
	
func shoot():
	var b = muddy.instantiate()
	owner.add_child(b)
	b.transform = $POINTY.global_transform
	
func attack():
	if(attackCooldown.is_stopped()):
		shoot()
		print("!!!")
		attackCooldown.start(attackSpeed)
		
func take_damage(amount: int):
	currentHealth -= amount
	print("muddy test")
	if currentHealth < 0:
		currentHealth = 0
		print("muddy is dead")
		self.queue_free()
		
		
func _physics_process(_delta):
	facing()
	attack()
