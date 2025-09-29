extends Area2D

func _ready():
	pass

func _input(event):
	if event.is_action_pressed('ui_accept'):
		print(get_overlapping_bodies().size())
