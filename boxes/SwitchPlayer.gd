extends Area2D

export(String, "Square", "Circle", "Triangle") var playerType = "Square"
export(String, "Top", "Right", "Bottom", "Left") var blockDirection = "Top"

signal changePlayer

onready var blocSprite = $BlocSprite
onready var shapeSprite = $ShapeSprite

var _err

func _ready():
	blocSprite.animation = blockDirection + "Off"
	shapeSprite.animation = playerType + "Off"
	add_to_group("switchBoxes")
	add_to_group("switchBoxes" + playerType)
	_err = connect("changePlayer", get_node("/root/Main"), "change_player")

func _on_area_entered(area):
	var object = area.get_parent()
	if object.speed > 0 && object.gameplayType == "Slide":
		# Deactivate active switchbox(es) and active current switchbox(es)
		get_tree().call_group("switchBoxes", "deactivate_box")
		get_tree().call_group("switchBoxes" + playerType, "activate_box")
		# Deactivate active movable(s) and active current movable(s)
		get_tree().call_group("movables", "deactivate_movable")
		get_tree().call_group("movables" + playerType, "activate_movable")
		emit_signal("changePlayer", playerType)

func activate_box():
	blocSprite.animation = blockDirection + "On"
	shapeSprite.animation = playerType + "On"
	
func deactivate_box():
	blocSprite.animation = blockDirection + "Off"
	shapeSprite.animation = playerType + "Off"
