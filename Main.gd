extends Node2D

export var activeLevel = ""

onready var currentLevel = $CurrentLevel

var playerType = "Square"
var gamePlayType = "Slide"
var canMove = true

func _ready():
	var levelInstance = load("res://levels/" + activeLevel + ".tscn").instance()
	currentLevel.add_child(levelInstance)
	change_player(levelInstance.playerType)
	change_gameplay(levelInstance.gameplayType)

func _physics_process(_delta):
	if canMove:
		if Input.is_action_just_pressed('ui_right'):
			move_objects("movables" + playerType, [1, 0])
		if Input.is_action_just_pressed('ui_left'):
			move_objects("movables" + playerType, [-1, 0])
		if Input.is_action_just_pressed('ui_up'):
			move_objects("movables" + playerType, [0, -1])
		if Input.is_action_just_pressed('ui_down'):
			move_objects("movables" + playerType, [0, 1])

func move_objects(groupName, dir):
	get_tree().call_group(groupName, "startMoving", dir)

func change_player(type):
	playerType = type
	
func change_gameplay(type):
	gamePlayType = type

func level_transition(levelName):
#	# Start fade transition
#	camera.start_screen_transition()
	canMove = false
	yield(get_tree().create_timer(.1), "timeout")
#	camera.smoothing_enabled = false
	# Destroy current level (this is SAVAGE)
	var level = currentLevel.get_child(0)
	level.queue_free()
	# Instantiate next level
	var levelInstance = load("res://levels/" + levelName + ".tscn").instance()
	currentLevel.add_child(levelInstance)
#	player.position = levelInstance.get_node("PlayerStartingPosition").position
#	yield(get_tree().create_timer(1), "timeout")
	canMove = true
#	camera.smoothing_enabled = true
#	# End fade transition
#	camera.end_screen_transition();
	print(gamePlayType)

func start_moving():
	canMove = false
	
func end_moving():
	canMove = true

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		quit_game()

func quit_game():
	get_tree().quit()
