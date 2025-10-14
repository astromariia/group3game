extends Node2D

@export var target_scene: PackedScene

func _ready()-> void:
	MusicController.bgm_play()
	
	var elf = $elf
	var slot = $elf/CanvasLayer/InventoryGui
	slot.set_item(elf.get_current_weapon_name())
	elf.connect("weapon_changed", Callable(slot, "set_item"))

func _process(delta: float) -> void:
	if get_tree().get_nodes_in_group("enemy").size() == 0:
		get_tree().change_scene_to_packed(target_scene)
