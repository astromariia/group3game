extends Node2D

var brush = preload("res://art/MediavelFree.png")
var strokes = []

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		strokes.append(event.position)
		update()

func _draw():
	for pos in strokes:
		draw_texture(brush, pos)
