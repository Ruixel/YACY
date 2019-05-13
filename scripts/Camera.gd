extends Camera

const camHeight = 4

enum CameraInput { Waiting, Pan, Zoom, Rotate }
var camInputState = CameraInput.Waiting

var mouse_motion = Vector2()

func _physics_process(delta):
	if Input.is_action_pressed("cam_pan") and (camInputState == CameraInput.Waiting or camInputState == CameraInput.Pan):
		if camInputState == CameraInput.Waiting:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			camInputState = CameraInput.Pan
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		camInputState = CameraInput.Waiting
		
	if camInputState == CameraInput.Pan:
		global_translate(Vector3(-mouse_motion.y * delta, 0, mouse_motion.x * delta))

func _input(event):
	if event is InputEventMouseMotion:
		mouse_motion = event.relative

func _ready():
	pass
