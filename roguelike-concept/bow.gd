extends CharacterBody2D
@onready var player : Node2D = %elf
@onready var _animated_sprite = $AnimatedSprite2D
@export var speed = 1.0
@export var facingDir = "left"
@export var mud : PackedScene
@onready var attackCooldown: Timer = $Timer

#code based on GPT input
func pointAt(player: Node2D, direction):
	var distance = 10
	var offset: Vector2 = Vector2.ZERO
	match direction.to_lower():
		"up":
			offset = Vector2(0,-distance)
			self.rotation_degrees=270
		"down":
			offset = Vector2(0,distance)
			self.rotation_degrees=90			
		"left":
			offset = Vector2(-distance,0)
			self.rotation_degrees=180
		"right":
			offset = Vector2(distance,0)
			self.rotation_degrees=0
	self.global_position = player.global_position + offset
	
#time in between attacks, in seconds
var attackSpeed = 1
#damage in HP
var damage = 1

func _ready():
	attackCooldown.one_shot = true
	attackCooldown.autostart = false
func shoot():
	_animated_sprite.play("shoot")
	$bowattack.play()
	var b = mud.instantiate()
	owner.add_child(b)
	b.transform = $Marker2D.global_transform
	
func attack():
	if attackCooldown.is_stopped() and Input.is_action_just_pressed("attack"):
		shoot()
		attackCooldown.start(attackSpeed)
func _physics_process(_delta):
	attack()
