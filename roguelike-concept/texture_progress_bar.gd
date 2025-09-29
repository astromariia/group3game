extends TextureProgressBar

@onready var player = get_tree().get_first_node_in_group("player")
var target_value : float = 100.0

func _ready():
	if player:
		player.healthChanged.connect(update)
	update()

func update():
	target_value = float(player.currentHealth * 100) / player.maxHealth
	var tween = create_tween()
	tween.tween_property(self, "value", target_value, 0.15)
	
