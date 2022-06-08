extends "res://entities/blocks/KineticBlock.gd"

export(String, "Square", "Circle", "Triangle") var blocType = "Square"

func _ready():
	sprite.animation = blocType + "Off"
	add_to_group("movables")
	add_to_group("movables" + blocType)

func activate_movable():
	sprite.animation = blocType + "On"

func deactivate_movable():
	sprite.animation = blocType + "Off"
