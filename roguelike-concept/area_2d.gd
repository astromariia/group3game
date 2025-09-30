extends Area2D
var speed = 200
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _collision_shape = $CollisionShape2D
@onready var player : Node2D = %elf
@onready var sploding = false
func _ready():
	body_entered.connect(_on_body_entered)
	
func _physics_process(delta):
	position += transform.x * speed * delta
	if sploding == false:
		_animated_sprite.play("shooty")
	
func _on_body_entered(body):
	print("Collided with: ", body.name)
	sploding = true
	speed = 0
	_animated_sprite.play("splode")

func _on_animated_sprite_2d_animation_finished() -> void:
	print("done attacking")
	$CollisionShape2D.queue_free()
	queue_free
