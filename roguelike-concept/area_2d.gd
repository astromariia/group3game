extends Area2D
var dir = Vector2.ZERO
var speed = 200
var damage = 1
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _collision_shape = $CollisionShape2D
@onready var sploding = false
func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += dir * speed * delta
	if sploding == false:
		_animated_sprite.play("shooty")
	
func _on_body_entered(body):
	print("Collided with: ", body.name)
	if body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
	sploding = true
	speed = 0
	_animated_sprite.play("splode")

func _on_animated_sprite_2d_animation_finished() -> void:
	print("done attacking")
	$CollisionShape2D.queue_free()
	queue_free
