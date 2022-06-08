extends KinematicBody2D

signal startMoving
signal endMoving

const TARGET_FPS = 60
const MAX_SPEED = 16
const ACCELERATION = 32
const GRID_STEP = 16

onready var trigger = $Trigger
onready var sprite = $Sprite
onready var checkCollisionTop = $CheckCollisionTop
onready var checkCollisionRight = $CheckCollisionRight
onready var checkCollisionBottom = $CheckCollisionBottom
onready var checkCollisionLeft = $CheckCollisionLeft
onready var checkCollisionStepTop = $CheckCollisionStepTop
onready var checkCollisionStepRight = $CheckCollisionStepRight
onready var checkCollisionStepBottom = $CheckCollisionStepBottom
onready var checkCollisionStepLeft = $CheckCollisionStepLeft

var moving = false
var gameplayType = ""
var direction = [0, 0]
var activeRaycast
var activeRaycastStep
var currentPoint = []
var targetPoint = []
var speed = 0
var viewportSize
var _err

func _ready():
	_err = connect("startMoving", get_node("/root/Main"), "start_moving")
	_err = connect("endMoving", get_node("/root/Main"), "end_moving")
	gameplayType = get_parent().gameplayType
	# Raycasts length
	viewportSize = get_viewport().size
	checkCollisionRight.cast_to.x = viewportSize[0]
	checkCollisionLeft.cast_to.x = -viewportSize[0]
	checkCollisionBottom.cast_to.y = viewportSize[1]
	checkCollisionTop.cast_to.y = -viewportSize[1]
	checkCollisionStepRight.cast_to.x = GRID_STEP
	checkCollisionStepLeft.cast_to.x = -GRID_STEP
	checkCollisionStepBottom.cast_to.y = GRID_STEP
	checkCollisionStepTop.cast_to.y = -GRID_STEP

func start_moving(dir):
	if !moving:
		direction = dir
		match gameplayType:
			"Slide", "Fall":
				# Calculate destination point to slide to
				set_active_raycast()
				set_target_point_slide()
			"Step":
				add_to_group("awaitingMoveStep")
				# Calculate destination point to step to
				set_active_raycast()
				set_target_point_step()
		currentPoint = position
		# Set trigger position
		trigger.position.x = GRID_STEP * direction[0]
		trigger.position.y = GRID_STEP * direction[1]
		add_to_group("isMoving")
		emit_signal("startMoving")
		# Start moving
		moving = true

func stop_moving():
	moving = false
	speed = 0
	# Set trigger position
	trigger.position.x = 0
	trigger.position.y = 0
	remove_from_group("isMoving")
	if get_tree().get_nodes_in_group("isMoving").empty():
		emit_signal("endMoving")
	if activeRaycastStep.is_colliding():
		var collider = activeRaycastStep.get_collider()
		if(collider.is_in_group("pushables")):
			collider.start_moving(direction)	
	direction = [0, 0]

func _physics_process(delta):
	if moving:
		# Increase speed
		speed += .8 * delta * TARGET_FPS
		speed = clamp(speed, 0, MAX_SPEED)
		# Move to destination
		position = position.move_toward(targetPoint, speed)
		# Stop moving if destination reached
		if position == targetPoint:
			stop_moving()


func set_active_raycast():
	if direction[0] == 1:
		activeRaycast = checkCollisionRight
		activeRaycastStep = checkCollisionStepRight
	elif direction[0] == -1:
		activeRaycast = checkCollisionLeft
		activeRaycastStep = checkCollisionStepLeft
	elif direction[1] == 1:
		activeRaycast = checkCollisionBottom
		activeRaycastStep = checkCollisionStepBottom
	elif direction[1] == -1:
		activeRaycast = checkCollisionTop
		activeRaycastStep = checkCollisionStepTop

func set_target_point_slide():
	var blocType = get_block_type()
	var collisionPoint = []
	# Get position of closest obstacle. If movable bloc is on the way,
	# ignore it and store it for later
	var obstacleDetected = false
	var colliders = []
	while !obstacleDetected:
		var collider = activeRaycast.get_collider()
		if collider.is_in_group("movables" + blocType):
			colliders.append(collider)
			activeRaycast.add_exception(collider)
			activeRaycast.force_raycast_update()
		else:
			collisionPoint = activeRaycast.get_collision_point()
			obstacleDetected = true
	# Remove current raycast exceptions. For each iteration, set targetPoint offset
	for collider in colliders:
		if direction[0] != 0:
			collisionPoint[0] += -direction[0] * GRID_STEP
		elif direction[1] != 0:
			collisionPoint[1] += -direction[1] * GRID_STEP
		activeRaycast.remove_exception(collider)
	# Set destination offset to snap to grid
	if direction[0] != 0:
		collisionPoint[0] += -direction[0] * GRID_STEP / 2.0
	elif direction[1] != 0:
		collisionPoint[1] += -direction[1] * GRID_STEP / 2.0
	# Set target point
	targetPoint = (Vector2(int(round(collisionPoint[0])), int(round(collisionPoint[1]))))

func set_target_point_step():
	var blocType = get_block_type()
	targetPoint = position
	if !activeRaycastStep.is_colliding():
		if direction[0] != 0:
			targetPoint.x -= -direction[0] * GRID_STEP
		elif direction[1] != 0:
			targetPoint.y -= -direction[1] * GRID_STEP
	elif activeRaycastStep.get_collider().is_in_group("movables" + blocType):
		var collisionPoint = []
		var collidersAmount = 0
		# Get position of closest obstacle. If movable bloc is on the way,
		# ignore it and store it for later
		var obstacleDetected = false
		var colliders = []
		while !obstacleDetected:
			var collider = activeRaycast.get_collider()
			if collider.is_in_group("movables" + blocType):
				colliders.append(collider)
				activeRaycast.add_exception(collider)
				activeRaycast.force_raycast_update()
				collidersAmount += 1
			else:
				collisionPoint = activeRaycast.get_collision_point()
				# Set collision point offset to snap to grid
				if direction[0] != 0:
					collisionPoint[0] += -direction[0] * GRID_STEP / 2.0
				elif direction[1] != 0:
					collisionPoint[1] += -direction[1] * GRID_STEP / 2.0
				obstacleDetected = true
		# Remove current raycast exceptions
		for collider in colliders:
			activeRaycast.remove_exception(collider)
		# Set target point
		targetPoint = position
		if direction[0] == 1:
			if position.x + (collidersAmount * GRID_STEP) < collisionPoint[0]:
				targetPoint[0] = position.x + GRID_STEP
		elif direction[0] == -1:
			if position.x - (collidersAmount * GRID_STEP) > collisionPoint[0]: 
				targetPoint[0] = position.x - GRID_STEP
		elif direction[1] == 1:
			if position.y + (collidersAmount * GRID_STEP) < collisionPoint[1]:
				targetPoint[1] = position.y + GRID_STEP
		elif direction[1] == -1:
			if position.y - (collidersAmount * GRID_STEP) > collisionPoint[1]:
				targetPoint[1] = position.y - GRID_STEP

func get_block_type():
	if is_in_group("movables"):
		return self.blocType
	else:
		return "Static"
