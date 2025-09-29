extends TextureProgressBar

# Reference to the player (Elf)
var player : Node = null
var target_value : float = 100.0

func _ready():
	call_deferred("_init_healthbar")

func _init_healthbar():
	player = get_tree().get_first_node_in_group("player")
	if player:
		print("Player Found")
		value = float(player.currentHealth * 100) / player.maxHealth
		player.healthChanged.connect(update_health)
	else: 
		print("Player not found")

func update_health():
	if not player:
		return
	target_value = float(player.currentHealth * 100) / player.maxHealth
	if value != target_value: 
		var tween = create_tween()
		tween.tween_property(self, "value", target_value, 0.05)
