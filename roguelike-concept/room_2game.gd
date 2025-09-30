extends Node2D

func _ready()-> void:
	MusicController.bgm_play()
	
	var elf = $elf
	var slot = $elf/CanvasLayer/InventoryGui
	slot.set_item(elf.get_current_weapon_name())
	elf.connect("weapon_changed", Callable(slot, "set_item"))
