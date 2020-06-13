extends KinematicBody

const rotationSpeed = 2.0 / 1000

# Player Controller Children
onready var camera = $FPSCamera

# GUI
onready var gui = $PlayerGUI
onready var gui_mouseLock = $PlayerGUI/MouseLockWarning

# Camera Variables
var lock_mouse = true
var yaw_delta = 0
var pitch_delta = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# Rotate camera horizontally and vertically
	self.rotate_y(yaw_delta * rotationSpeed)
	camera.rotate_x(pitch_delta * rotationSpeed)
	yaw_delta = 0
	pitch_delta = 0

func _physics_process(delta):
	# Horizontal Camara Rotation
	pass

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
