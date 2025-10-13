extends Area2D

@export var damage: int = 5
@export var instigator: Node = null   
@export var ignore_group: String = ""       

func _ready() -> void:
	monitoring = true
	monitorable = true
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body == instigator:
		return
	if ignore_group != "" and body.is_in_group(ignore_group):
		return
	if body and body.has_method("take_damage"):
		print(str(body))
		body.take_damage(damage)
