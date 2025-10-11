extends CharacterBody2D
@onready var _animated_sprite = $AnimatedSprite2D
@export var speed = 0.5
@onready var player : Node2D = %elf
@onready var attackCooldown: Timer = $SlugAttack
@export var patrollocations = PackedVector2Array([Vector2(350,160),Vector2(350,40)])
#time in between attacks, in seconds
var attackSpeed = 1
#damage in HP
var damage = 1
var i = 0
	
func _ready():
	attackCooldown.one_shot = true
	attackCooldown.autostart = false
	_animated_sprite.play("default")	


func move():
	
	var playerPos = player.global_position
	var selfPos = self.global_position
	var inRange = playerPos - selfPos
	var input_direction = patrollocations[i] - selfPos
	
	if (inRange.length() <= 20):
		attack()
	else:
		if input_direction.length() <=10:
			i+=1
			print("!")
			if i >= len(patrollocations):
				i=0
		velocity = input_direction.normalized() * speed

	if input_direction.x < 0:
		_animated_sprite.flip_h = true
	elif input_direction.x > 0:
		_animated_sprite.flip_h = false

func attack():
	if(attackCooldown.is_stopped()):
		print("ouch x" + str(damage))
		if player.has_method("take_damage"):
			player.take_damage(damage)
			$attacknoises.play()
		attackCooldown.start(attackSpeed)
	

func _physics_process(_delta):
	move()
	var collision := move_and_collide(velocity)
	if collision != null:
		var body := collision.get_collider()
