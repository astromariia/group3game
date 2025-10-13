extends Area2D
var damage = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	print("Collided with: ", body.name)
	if body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
