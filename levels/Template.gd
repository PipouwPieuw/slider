extends Node2D

export(String, "Square", "Circle", "Triangle") var playerType = "Square"
export(String, "Slide", "Step", "Fall") var gameplayType = "Slide"

signal initializePlayer
signal initializeGameplay

var _err

func _ready():
	# Activate current switchbox(es)
	get_tree().call_group("switchBoxes" + playerType, "activate_box")
	# Activate current movable(s)
	get_tree().call_group("movables" + playerType, "activate_movable")
	# Activate player
	_err = connect("initializePlayer", get_node("/root/Main"), "change_player")
	_err = connect("initializeGameplay", get_node("/root/Main"), "change_gameplay")
	emit_signal("initializePlayer", playerType)
	emit_signal("initializeGameplay", gameplayType)
