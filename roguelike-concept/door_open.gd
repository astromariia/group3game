extends Area2D

@export var target_scene: PackedScene   # assign this in Inspector

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  # Add elf to "player" group in editor
		if target_scene:
			get_tree().change_scene_to_packed(target_scene)

			
