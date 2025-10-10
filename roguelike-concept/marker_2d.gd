extends Marker2D
@export var patrollocations = PackedVector2Array([Vector2(0,63),Vector2(-126,63)])
var i = 0
func _ready():
	self.global_position = patrollocations[0]
	print(self.global_position.x)
func _on_body_entered(body: Node2D) -> void:
	if body.is($slug_box):
		print("!!!")
		if i == range(patrollocations):
			i = 0
			self.global_position = patrollocations[i]
		else:
			self.global_position = patrollocations[i]
			i=i+1
