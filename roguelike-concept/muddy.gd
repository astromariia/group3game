extends CharacterBody2D
@onready var pointer : Node2D = $POINTY
@onready var player : Node2D = %elf
@onready var _animated_sprite = $AnimatedSprite2D
@export var speed = 0.5
@export var facingDir = "left"
@export var mud : PackedScene
@onready var attackCooldown: Timer = $ShootyCooldown


var HP = 10
var currentHealth = HP


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


#time in between attacks, in seconds
var attackSpeed = 1
#damage in HP
var damage = 1

func _ready():
	attackCooldown.one_shot = true
	attackCooldown.autostart = false
func shoot():
	$mudshot.play()
	var b = mud.instantiate()
	owner.add_child(b)
	match facingDir.to_lower():
		"up":
			b.dir = Vector2(0,-1)
		"down":
			b.dir = Vector2(0,1)
		"left":
			b.dir = Vector2(1,0)
		"right":
			b.dir  = Vector2(-1,0)
	b.transform = $POINTY.global_transform
	
func attack():
	if(attackCooldown.is_stopped()):
		shoot()
		attackCooldown.start(attackSpeed)
		
func take_damage(amount: int):
	currentHealth -= amount
	if currentHealth < 0:
		currentHealth = 0
		print("muddy is dead")
		self.queue_free()


func _physics_process(_delta):
	facing()
	attack()
