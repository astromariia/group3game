extends Node2D

func _ready()-> void:
	MusicController.bgm_play()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://room_2.tscn")



func _on_button_2_pressed() -> void:
	get_tree().quit()
