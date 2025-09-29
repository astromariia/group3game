extends Control

@onready var icon: TextureRect = $Icon  # make sure the TextureRect is a child named "Icon"

# Dictionary of item icons
var item_icons = {
	"Bow": preload("res://Art/0x72_DungeonTilesetII_v1.7/frames/weapon_bow.png")
	# Add other items like "Sword" here
}

func set_item(item_name: String) -> void:
	if item_icons.has(item_name):
		icon.texture = item_icons[item_name]
		icon.expand = true
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	else:
		icon.texture = null
