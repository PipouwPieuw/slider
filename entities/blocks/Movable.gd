extends "res://entities/blocks/KineticBlock.gd"

export(String, "Square", "Circle", "Triangle") var blockType = "Square"

func _ready():
	sprite.animation = blockType + "Off"
	add_to_group("movables")
	add_to_group("movables" + blockType)

func activate_movable():
	sprite.animation = blockType + "On"

func deactivate_movable():
	sprite.animation = blockType + "Off"
