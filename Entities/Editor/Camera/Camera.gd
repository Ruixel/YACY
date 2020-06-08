extends Spatial

const CAM_ZOOM_MIN = 5
const CAM_ZOOM_MAX = 20

const CAM_ANGLE_MIN = 15.0
const CAM_ANGLE_MAX = 85.0

const CAM_DRAG_SPEED = 0.5

onready var EditorGUI = get_node("../GUI")

var camPosition = Vector2(0, 10)
var camAngle = 35.0
var camZoom = 6
var camHeight = 0

var mouse_motion = Vector2()

func _ready() -> void:
	EditorGUI.get_node("MapLevel").connect("s_changeLevel", self, "on_level_change")

func on_level_change(level):
	camHeight = WorldConstants.LEVEL_HEIGHT * (level - 1)

func _process(delta: float) -> void:
	if Input.is_action_pressed("editor_camera_pan"):
		# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		# Drag across level relative to camera angle
		var ang = self.rotation.y
		var y_speed = mouse_motion.y * delta
		var x_speed = mouse_motion.x * delta
		camPosition.x += CAM_DRAG_SPEED * ((cos(self.rotation.y) * y_speed)  + (sin(self.rotation.y) * -x_speed))
		camPosition.y += CAM_DRAG_SPEED * ((sin(self.rotation.y) * -y_speed) + (cos(self.rotation.y) * -x_speed))
		
	elif Input.is_action_pressed("editor_camera_rotate"):
		# Rotate up/down
		camAngle += mouse_motion.y * delta * 10
		camAngle  = clamp(camAngle, 15.0, 85.0)
		
		# Rotate side to side
		self.rotate_y(-mouse_motion.x * delta * 0.2)
	else:
		# Show mouse if doing nothing
		# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pass
	
	# Move the camera away from the target (zoom distance)
	$Camera.transform.origin.y = sin(deg2rad(camAngle)) * camZoom
	$Camera.transform.origin.x = -cos(deg2rad(camAngle)) * camZoom
	$Camera.rotation.x         = -deg2rad(camAngle)
	
	# Lerp camera to match grid position
	var finalPos = Vector3(camPosition.x, camHeight, camPosition.y)
	self.global_transform.origin = lerp(self.global_transform.origin, finalPos, 0.4)
	
	# Reset mouse movement
	mouse_motion = Vector2(0, 0)

func _input(event: InputEvent) -> void:
	# Mouse movement
	if event is InputEventMouseMotion:
		mouse_motion = event.relative

func _unhandled_input(event: InputEvent) -> void:
	# Mouse scroll
	if event.is_action_pressed("editor_camera_zoom_in"):
		camZoom -= 1
		camZoom = clamp(camZoom, CAM_ZOOM_MIN, CAM_ZOOM_MAX)
	if event.is_action_pressed("editor_camera_zoom_out"):
		camZoom += 1
		camZoom = clamp(camZoom, CAM_ZOOM_MIN, CAM_ZOOM_MAX)
