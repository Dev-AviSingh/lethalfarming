extends Node2D

var player:Node2D

func _ready():
	player = get_parent()

func updateHealth():
	$"Health Bar/Fill".scale.x = player.health /player.maxHealth

func updateArmor():
	$"Armor Bar/Fill".scale.x = player.armorHealth /player.maxArmorHealth
