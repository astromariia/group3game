extends CharacterBody2D
@onready var pointer : Node2D = $slimypoint
@onready var player : Node2D = %elf
@onready var _animated_sprite = $AnimatedSprite2D
@export var speed = 0.5
@export var facingDir = "left"
@export var mud : PackedScene
@onready var attackCooldown: Timer = $ShootyCooldown


var HP = 15
var currentHealth = HP


func facing():
	var playerPos = player.global_position
	var selfPos = self.global_position
	if playerPos.x > selfPos.x:
		_animated_sprite.flip_h = false
		_animated_sprite.play("spit")
		if playerPos.y > selfPos.y:
			facingDir = "upleft"
		else:
			facingDir = "downleft"
	else:
		_animated_sprite.flip_h = true
		_animated_sprite.play("spit")
		if playerPos.y > selfPos.y:
			facingDir = "upright"
		else:
			facingDir = "downright"
	
	pointer.pointAt(self, facingDir)


#time in between attacks, in seconds
var attackSpeed = 1
#damage in HP
var damage = 4

func _ready():
	attackCooldown.one_shot = true
	attackCooldown.autostart = false
func shoot():
	$mudshot.play()
	var b = mud.instantiate()
	owner.add_child(b)
	match facingDir.to_lower():
		"upleft":
			b.dir = Vector2(1,1)
		"downleft":
			b.dir = Vector2(1,-1)
		"downright":
			b.dir = Vector2(-1,-1)
		"upright":
			b.dir  = Vector2(-1,1)
	b.transform = $slimypoint.global_transform
	
func attack():
	if(attackCooldown.is_stopped()):
		shoot()
		attackCooldown.start(attackSpeed)
		
func take_damage(amount: int):
	currentHealth -= amount
	if currentHealth < 0:
		currentHealth = 0
		print("slimy is dead")
		self.queue_free()


func _physics_process(_delta):
	facing()
	attack()
