extends Marker2D

var i = 0
func _ready():
	self.global_position = patrollocations[i]
	print(self.global_position.x)
	
func stepin():
	var distance = $slug.global_position - global_position
	if  distance < 40:
		print("!!!")
		if i == range(patrollocations):
			i = 0
			self.global_position = patrollocations[i]
		else:
			i=i+1
			self.global_position = patrollocations[i]
