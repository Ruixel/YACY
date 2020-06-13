extends KinematicBody

const rotationSpeed = 2.0 / 1000
const maxSpeedOnGround = 3
const movementSharpnessGround = 10

# Player Controller Children
onready var camera = $FPSCamera

# GUI
onready var gui = $PlayerGUI
onready var gui_mouseLock = $PlayerGUI/MouseLockWarning

# Camera Variables
var lock_mouse = true
var yaw_delta = 0
var pitch_delta = 0

# Movement Variables
var targetVelocity : Vector3 = Vector3()
var charVelocity : Vector3 = Vector3()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# Rotate camera horizontally and vertically
	self.rotate_y(yaw_delta * rotationSpeed)
	camera.rotate_x(pitch_delta * rotationSpeed)
	yaw_delta = 0
	pitch_delta = 0

func _physics_process(delta):
	targetVelocity = getMoveDirection() * maxSpeedOnGround
	charVelocity = charVelocity.linear_interpolate(targetVelocity, movementSharpnessGround * delta)
	
	checkIfGrounded()
	
	move_and_slide(charVelocity, Vector3(0, 1, 0))

func checkIfGrounded():
	if (test_move(transform, Vector3(0, -0.2, 0))):
		print("on the ground")
	else:
		print("off")
		charVelocity = charVelocity + Vector3(0, -9, 0)

func _unhandled_input(event):
	if event is InputEventMouseMotion and lock_mouse:
		pitch_delta -= event.relative.y
		yaw_delta -= event.relative.x
	
	if event is InputEventKey and event.pressed:
		if event.is_action("toggle_mouse_lock"):
			lock_mouse = not lock_mouse
			match lock_mouse:
				true: 
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					gui_mouseLock.visible = false
				false: 
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					gui_mouseLock.visible = true

func getMoveDirection() -> Vector3:
	var dirVector = Vector3()
	if Input.is_action_pressed("move_forward"):
		dirVector += (-camera.global_transform.basis.z * Vector3(1,0,1)).normalized()
	if Input.is_action_pressed("move_back"):
		dirVector += (camera.global_transform.basis.z * Vector3(1,0,1)).normalized()
	if Input.is_action_pressed("move_left"):
		dirVector += (-camera.global_transform.basis.x * Vector3(1,0,1)).normalized()
	if Input.is_action_pressed("move_right"):
		dirVector += (camera.global_transform.basis.x * Vector3(1,0,1)).normalized()
	
	return dirVector
