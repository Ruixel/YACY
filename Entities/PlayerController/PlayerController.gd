extends KinematicBody

const rotationSpeed = 2.0 / 1000
const maxSpeedOnGround = 3.5
const maxSpeedinAir = 4
var speedMultiplier = 1.0
const movementSharpnessGround = 10
const jumpForce = 6.5
var onLadder = false
var ladderNormal := Vector3()
var ladderUpVector := Vector3()
var ladderCrossVector := Vector3()
var canMove := true
var gravity := 18.0
var spawnPoint := Transform()

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
var camera_show_body = [false, true, true]
enum CAMERA_TYPE { FPS, BEHIND, FRONT }
var cType = CAMERA_TYPE.FPS
var currentCam
const underwater_env = preload("res://Scenes/Env/Underwater.tres")

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

# Inventory
# TODO: Move to separate file?
var keys = []
const master_key = WorldConstants.MASTER_KEY
var diamonds = 0
var hasSlingshot := false
var ammo := 0
var chased_by_chaser = null

var busy : bool = false
var tp_busy : bool = false
var pause : bool = false
var invulnerable : bool = false

# Signals
signal s_updateAmmo
signal s_disabled
signal s_enabled
signal s_newChaser

func _ready():
	_setup()
	
	self.connect("s_updateAmmo", self, "updateAmmo")
	var pause_node = get_node_or_null("../PauseMenu")
	if pause_node != null:
		pause_node.connect("pause", self, "onPause")
		pause_node.connect("unpause", self, "onUnpause")

func _setup():
	set_meta("player", true)
	lock_mouse = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	changeCameraAngle(CAMERA_TYPE.FPS)
	currentCam = $EyePoint/FPSCamera

func reset():
	flying = false
	canFly = false
	busy = false
	tp_busy = false
	pause = false
	invulnerable = false
	fuel_amount = 0.0
	keys = []
	diamonds = 0
	gravity = 18
	canMove = true
	hasSlingshot = false
	ammo = 0
	speedMultiplier = 1.0
	
	$PlayerGUI.reset()
	$AudioNode/Jetpack.stop()
	$Back/Jetpack.visible = false
	$Back/Jetpack/Fire.visible = false
	
	# Remove weapons
	for wep in $EyePoint/Hand.get_children():
		wep.queue_free()
	
	# Remove attachments
	for obj in $Attachments.get_children():
		obj.queue_free()

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
	
	if onLadder:
		var direction = getMoveDirection()
		direction = direction.slide(self.ladderNormal).normalized()
		
		var dot_product = direction.dot(self.ladderUpVector)
		if abs(dot_product) > 0.7:
			if dot_product > 0:
				charVelocity = ladderUpVector * 3.5
			if dot_product < 0:
				charVelocity = ladderUpVector * -3.5
		else:
			var slide = direction.slide(self.ladderNormal).normalized() 
			charVelocity = (slide.project(self.ladderUpVector) * 5.0) + (slide.project(self.ladderCrossVector) * 1.0)
		
		if (Input.is_action_pressed("jump") and canMove):
			charVelocity = Vector3(charVelocity.x, 0, charVelocity.z)
			charVelocity += Vector3.UP * jumpForce
			onFloorLastFrame = false
	elif (not flying && is_on_floor()):
		onFloorLastFrame = true
		targetVelocity = getMoveDirection() * maxSpeedOnGround * speedMultiplier
		targetVelocity += Vector3(0, -5, 0)
		charVelocity = charVelocity.linear_interpolate(targetVelocity, movementSharpnessGround * delta)
		
		if (Input.is_action_pressed("jump") and canMove):
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
			if (horizontalVelocity.length() > maxSpeedinAir * speedMultiplier):
				horizontalVelocity = horizontalVelocity.normalized() * maxSpeedinAir * speedMultiplier
			
			charVelocity = Vector3(horizontalVelocity.x, charVelocity.y, horizontalVelocity.z)
			charVelocity += Vector3.DOWN * gravity * delta
	
	#move_and_slide_with_snap(charVelocity, Vector3(0, -2, 0), Vector3(0, 1, 0))
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
		if event.is_action_pressed("toggle_flight") and canFly and canMove and not busy and fuel_amount > 0:
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
		if event.is_action_pressed("drop_crumb") and canMove:
			dropCrumb()

func getOnLadder(ladderNormal: Vector3, ladderUpVector: Vector3):
	self.ladderNormal = ladderNormal
	self.ladderUpVector = ladderUpVector
	self.ladderCrossVector = ladderUpVector.cross(ladderNormal)
	
	onLadder = true

func getOffLadder():
	onLadder = false

func getMoveDirection() -> Vector3:
	if not self.canMove:
		return Vector3(0,0,0)
		
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
	if not self.canMove:
		return Vector3(0,0,0)
		
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
	changeCameraAngle(newCamAngleIndex)

func changeCameraAngle(index):
	cType = index
	$PlayerBody.visible = camera_show_body[index]
	$PlayerHead.visible = camera_show_body[index]
	$Back.visible = camera_show_body[index]
	
	var camAngle = camera_angles[index]
	camAngle.make_current()
	currentCam = camAngle

func fallInWater():
	# TODO: Move to its own function
	if flying:
		flying = false
		$PlayerGUI.toggleJetpack(flying)
		$AudioNode/Jetpack.stop()
		$Back/Jetpack/Fire.visible = false
	
	$AudioNode/Splash.play()
	gravity = 1
	charVelocity = Vector3(0, -2, 0)
	canMove = false
	busy = true
	currentCam.environment = underwater_env
	
	yield(get_tree().create_timer(2.5), "timeout")
	
	gravity = 18
	charVelocity = Vector3(0, 0, 0)
	canMove = true
	busy = false
	currentCam.environment = null
	self.set_transform(self.spawnPoint)

func setSpawnPoint(transform: Transform):
	self.spawnPoint = transform

func pickupJetpack(has_unlimited_fuel: bool) -> bool:
	if not canFly:
		canFly = true
		unlimited_fuel = has_unlimited_fuel
		
		if has_unlimited_fuel:
			fuel_amount = max_fuel
		
		$Back/Jetpack.visible = true
		$PlayerGUI.pickupJetpack()
		$PlayerGUI.updateJetpackFuel(fuel_amount, max_fuel)
		return true
	
	return false

func pickupFuel(amount: int) -> bool:
	if fuel_amount < max_fuel:
		fuel_amount = min(fuel_amount + amount, max_fuel)
		$PlayerGUI.updateJetpackFuel(fuel_amount, max_fuel)
		return true
	
	return false

func pickupKey(key: int):
	# If it's a master key, replace all keys with master
	if key in self.keys or master_key in self.keys:
		return
	if key == master_key:
		self.keys = [master_key]
		$PlayerGUI.updateKeys(self.keys)
		return
		
	self.keys.append(key)
	$PlayerGUI.updateKeys(self.keys)

func pickupDiamond(time_save: int = 0):
	self.diamonds += 1
	$PlayerGUI.updateDiamonds(self.diamonds)
	$PlayerGUI.time_save(time_save)

func pickupSlingshot() -> bool:
	if not hasSlingshot:
		var slingshot = preload("res://Entities/PlayerController/Slingshot/Slingshot.tscn").instance()
		slingshot.connect("s_updateAmmo", self, "updateAmmo")
		slingshot.add_connection(self)
		$EyePoint/Hand.add_child(slingshot)
		
		emit_signal("s_updateAmmo", self.ammo)
		hasSlingshot = true
		return true
	
	return false

func updateAmmo(ammo: int):
	self.ammo = ammo
	$PlayerGUI.updateCrumbs(ammo)

func pickupCrumbs(amount: int):
	emit_signal("s_updateAmmo", ammo + amount)

func dropCrumb():
	if self.ammo > 0:
		var crumb = preload("res://Entities/PlayerController/Slingshot/CrumbDrop.tscn").instance()
		var level_debris = get_parent().get_node("LevelDebris")
		level_debris.add_child(crumb)
		crumb.global_translate(self.global_transform.origin)
		
		self.ammo -= 1
		emit_signal("s_updateAmmo", self.ammo)

func hasKey(key: int) -> bool:
	if key in self.keys or master_key in self.keys:
		return true
	return false

func freeze():
	if invulnerable:
		return
	
	$AudioNode/Freeze.play()
	self.busy = true
	self.canMove = false
	self.invulnerable = true
	emit_signal("s_disabled")
	
	gui.freezeScreen(3.6)
	yield(get_tree().create_timer(3.3), "timeout")
	
	self.busy = false
	self.canMove = true
	emit_signal("s_enabled")
	
	# Wait a while for the player to move around
	yield(get_tree().create_timer(2.5), "timeout")
	self.invulnerable = false

# Chaser stuff
func activate_chaser(chaser):
	if chased_by_chaser != null:
		chased_by_chaser.disable()
	
	chased_by_chaser = chaser

func deactivate_chaser(chaser):
	if chased_by_chaser == chaser:
		chased_by_chaser = null

func chaser_triggered(chaser):
	if chased_by_chaser == chaser:
		speedMultiplier = 0.3

func chaser_untriggered(chaser):
	if chased_by_chaser == chaser:
		speedMultiplier = 1.0

func finish_level():
	gui.display_level_finish()
	
	self.busy = true
	self.canMove = false
	self.invulnerable = true
	self.lock_mouse = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	emit_signal("s_disabled")

func onPause():
	busy = true
	pause = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	gui.visible = false

func onUnpause():
	busy = false
	pause = false
	
	if lock_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gui.visible = true
