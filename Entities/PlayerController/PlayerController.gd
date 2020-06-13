extends KinematicBody

const rotationSpeed = 2.0 / 1000

# Player Controller Children
onready var camera = $FPSCamera

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
	if event is InputEventMouseMotion:
		pitch_delta -= event.relative.y
		yaw_delta -= event.relative.x
		
