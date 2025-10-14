
extends Area2D

@export var damage: int = 5
@export var ignore_group: String = "enemies"  # optional, so enemies/boss don’t get hurt

func _ready() -> void:
	monitoring = true
	monitorable = true
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# don’t hurt enemies if you use an "enemies" group for AI/bosses
	if ignore_group != "" and body.is_in_group(ignore_group):
		return
	if body and body.has_method("take_damage"):
		body.take_damage(damage)
