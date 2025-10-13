extends Area2D

@export var damage: int = 5

func _ready() -> void:
	# Ensure we actually emit body_entered signals
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body and body.has_method("take_damage"):
		print(str(body))
		body.take_damage(damage)
