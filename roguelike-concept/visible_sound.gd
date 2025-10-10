extends Control

var visible_characters = 0

func _process(delta):
	if visible_characters != $RichTextLabel.visible_characters:
		visible_characters = $RichTextLabel.visible_characters
		$Audio.play()
		$Audio.volume_db = 20


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
