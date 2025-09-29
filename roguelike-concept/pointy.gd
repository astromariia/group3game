extends Marker2D
#code based on GPT input
@onready var attatchedBeing : Node2D = $muddy
func pointAt(attachedBeing: Node2D, direction):
	var distance = 20
	var offset: Vector2 = Vector2.ZERO
	match direction.to_lower():
		"up":
			offset = Vector2(0,distance)
		"down":
			offset = Vector2(0,-distance)
		"left":
			offset = Vector2(distance,0)
		"right":
			offset = Vector2(-distance,0)
	self.global_position = attachedBeing.global_position + offset
