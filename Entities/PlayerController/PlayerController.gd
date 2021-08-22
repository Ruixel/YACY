extends KinematicBody

const rotationSpeed = 2.0 / 1000
const maxSpeedOnGround = 3.5
const maxSpeedinAir = 4
const movementSharpnessGround = 10
const jumpForce = 6.5
const gravity = 18

# Player Controller Children
onready var camera = $EyePoint

# GUI
onready var gui = $PlayerGUI
onready var gui_mouseLock = $PlayerGUI/MouseLockWarning

# Camera Variables
var lock_mouse = true
var yaw_delta = 0
var pitch_delta = 0
var pitch = 0
onready var camera_angles = [$EyePoint/FPSCamera, $EyePoint/TPSCameraBehind, $EyePoint/TPSCameraFront ]
enum CAMERA_TYPE { FPS, BEHIND, FRONT }
var cType = CAMERA_TYPE.FPS

# Movement Variables
var targetVelocity : Vector3 = Vector3()
var charVelocity : Vector3 = Vector3()
var onFloorLastFrame : bool = false

# Flight variables
var flying: bool = false
var canFly: bool = false
var unlimited_fuel: bool = true
var fuel_amount: float = 0.0
const max_fuel: float = 240.0

var busy : bool = false
var pause : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func reset():
	flying = false
	canFly = false
	busy = false
	pause = false
	
	$PlayerGUI.reset()
	$AudioNode/Jetpack.stop()
	$Back/Jetpack.visible = false
	$Back/Jetpack/Fire.visible = false

func _process(delta):
	# Rotate camera horizontally and vertically
	self.rotate_y(yaw_delta * rotationSpeed)
	camera.rotate_x(pitch_delta * rotationSpeed)
	$PlayerHead.rotate_x(pitch_delta * rotationSpeed / 2.0)
	yaw_delta = 0
	pitch_delta = 0
	var pitch = camera.transform.basis.get_euler().x
	
	# Fuel stuff
	if flying and not unlimited_fuel:
		fuel_amount -= delta
		$PlayerGUI.updateJetpackFuel(fuel_amount, max_fuel)
		
		if fuel_amount < 0:
			fuel_amount = 0.0
			flying = false
			$PlayerGUI.toggleJetpack(flying)
			$AudioNode/Jetpack.stop()

func _physics_process(delta):
	if pause:
		return
	#checkIfGrounded()
	
	if (not flying && is_on_floor()):
		onFloorLastFrame = true
		targetVelocity = getMoveDirection() * maxSpeedOnGround
		targetVelocity += Vector3(0, -5, 0)
		charVelocity = charVelocity.linear_interpolate(targetVelocity, movementSharpnessGround * delta)
		
		if (Input.is_action_pressed("jump")):
			charVelocity = Vector3(charVelocity.x, 0, charVelocity.z)
			charVelocity += Vector3.UP * jumpForce
			onFloorLastFrame = false
	else:
		# Cancel out high gravity used to snap player to ground
		if onFloorLastFrame == true or is_on_ceiling():
			charVelocity = Vector3(charVelocity.x, 0, charVelocity.z)
		onFloorLastFrame = false
		
		# Air Strafing
		if (flying):
			charVelocity += getFlyMoveDirection() * 20 * delta
			charVelocity *= 0.92
		else:
			charVelocity += getMoveDirection() * 15 * delta
			
			var horizontalVelocity = Plane(Vector3.UP, 0).project(charVelocity)
			horizontalVelocity *= 0.95
			if (horizontalVelocity.length() > maxSpeedinAir):
				horizontalVelocity = horizontalVelocity.normalized() * maxSpeedinAir
			
			charVelocity = Vector3(horizontalVelocity.x, charVelocity.y, horizontalVelocity.z)
			charVelocity += Vector3.DOWN * 18 * delta
	
	move_and_slide(charVelocity, Vector3(0, 1, 0))

func checkIfGrounded():
	var space = get_world().direct_space_state as PhysicsDirectSpaceState
	var params = PhysicsShapeQueryParameters.new()
	params.exclude = [self]
	params.set_shape($CollisionShape.shape)
	params.set_transform($CollisionShape.global_transform)

	var motionTest = space.cast_motion(params, Vector3(0, -1, 0))
	print (motionTest)
	
	# Get collision info
	params.transform.origin += Vector3(0, -1, 0) * motionTest[1]
	var restInfo = space.get_rest_info(params)
	if (not restInfo.empty()):
		var angle = Vector3(0, 1, 0).dot(restInfo["normal"])
		print("Normal: " + str(angle))
	
	if (motionTest[0] < 0.1):
		self.transform.origin += Vector3(0, -1, 0) * motionTest[0]
	
#	if (test_move(transform, Vector3(0, -0.2, 0))):
#		print("on the ground")
#	else:
#		print("off")
#		charVelocity = charVelocity + Vector3(0, -1, 0)

func _unhandled_input(event):
	if event is InputEventMouseMotion and lock_mouse:
		var new_pitch = pitch + (-event.relative.y * rotationSpeed)
		if (new_pitch < (PI/2 - 0.1)) and (new_pitch > (-PI/2 + 0.1)):
			pitch_delta -= event.relative.y
			pitch = new_pitch
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
		if event.is_action_pressed("toggle_flight") and canFly and not busy and fuel_amount > 0:
			flying = not flying
			$PlayerGUI.toggleJetpack(flying)
			if flying:
				$AudioNode/Jetpack.play()
				$Back/Jetpack/Fire.visible = true
			else:
				$AudioNode/Jetpack.stop()
				$Back/Jetpack/Fire.visible = false
		if event.is_action_pressed("change_view"):
			toggleCameraAngle()

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

func getFlyMoveDirection() -> Vector3:
	var dirVector = Vector3()
	if Input.is_action_pressed("move_forward"):
		dirVector += (-camera.global_transform.basis.z * Vector3(1,1,1)).normalized()
	if Input.is_action_pressed("move_back"):
		dirVector += (camera.global_transform.basis.z * Vector3(1,1,1)).normalized()
	if Input.is_action_pressed("move_left"):
		dirVector += (-camera.global_transform.basis.x * Vector3(1,1,1)).normalized()
	if Input.is_action_pressed("move_right"):
		dirVector += (camera.global_transform.basis.x * Vector3(1,1,1)).normalized()
	if Input.is_action_pressed("jump"):
		dirVector += Vector3(0,1,0)
	if Input.is_action_pressed("crouch"):
		dirVector += Vector3(0,-1,0)
	
	return dirVector

func toggleCameraAngle():
	var numCameraAngles = camera_angles.size()
	var newCamAngleIndex = (cType + 1) % numCameraAngles
	var camAngle = camera_angles[newCamAngleIndex]
	
	cType = newCamAngleIndex
	camAngle.make_current()

func pickupJetpack(has_unlimited_fuel: bool):
	canFly = true
	unlimited_fuel = has_unlimited_fuel
	
	if has_unlimited_fuel:
		fuel_amount = max_fuel
	
	$Back/Jetpack.visible = true
	$PlayerGUI.pickupJetpack()
	$PlayerGUI.updateJetpackFuel(fuel_amount, max_fuel)

func pickupFuel(amount: int):
	fuel_amount = min(fuel_amount + amount, max_fuel)
	
	$PlayerGUI.updateJetpackFuel(fuel_amount, max_fuel)
