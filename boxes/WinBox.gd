extends Area2D

export var targetLevel = "0001"

signal gotoNextLevel

var _err

func _ready():
	_err = connect("gotoNextLevel", get_node("/root/Main"), "level_transition")

func _on_area_entered(_area):
	emit_signal("gotoNextLevel", targetLevel)

#func _on_body_entered(body):
#	if body.is_in_group("movables"):
#		emit_signal("gotoNextLevel", targetLevel)
