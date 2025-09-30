extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@export var speed = 0.5
@onready var player : Node2D = %elf
@onready var attackCooldown: Timer = $AttackCooldownTimer

#time in between attacks, in seconds
var attackSpeed = 1
#damage in HP
var damage = 1

func _ready():
	attackCooldown.one_shot = true
	attackCooldown.autostart = false


func move():
	
	var playerPos = player.global_position
	var selfPos = global_position
	var input_direction = playerPos - selfPos

	if (input_direction.length() <= 20):
		attack()
	else:
		velocity = input_direction.normalized() * speed

	if input_direction.x < 0:
		_animated_sprite.flip_h = true
		_animated_sprite.play("goblin_run")
	elif input_direction.x > 0:
		_animated_sprite.flip_h = false
		_animated_sprite.play("goblin_run")	
	else:
		_animated_sprite.play("goblin_idle")
		
func attack():
	if(attackCooldown.is_stopped()):
		print("ouch x" + str(damage))
		if player.has_method("take_damage"):
			player.take_damage(damage)
		attackCooldown.start(attackSpeed)
	

func _physics_process(_delta):
	move()
	var collision := move_and_collide(velocity)
	if collision != null:
		var body := collision.get_collider()
		
