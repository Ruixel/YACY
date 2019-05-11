extends Camera

const camHeight = 4

enum CameraInput { Waiting, Pan, Zoom, Rotate }
var camInputState = CameraInput.Waiting

func _ready():
	pass # Replace with function body.
