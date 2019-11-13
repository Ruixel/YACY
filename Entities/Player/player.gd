extends KinematicBody


var aiming = false
const CAMERA_ROTATION_SPEED = 0.001
const GRAVITY = Vector3(0,-9.8, 0)
const DIRECTION_INTERPOLATE_SPEED = 1

const MOTION_INTERPOLATE_SPEED = 10
const ROTATION_INTERPOLATE_SPEED = 10
var motion = Vector2()

const CAMERA_X_ROT_MIN = -40
const CAMERA_X_ROT_MAX = 30

var camera_x_rot = 0.0

var velocity = Vector3()

var orientation = Transform()

var airborne_time = 100
const MIN_AIRBORNE_TIME = 0.1

onready var cam_origin = $"camera_base/camera_rot/c_origin"
onready var cam_end = $"camera_base/camera_rot/c_end"

const JUMP_SPEED = 5

var root_motion = Transform()

func _input(event):
	if event is InputEventMouseMotion:
		$camera_base.rotate_y( -event.relative.x * CAMERA_ROTATION_SPEED )
		$camera_base.orthonormalize() # after relative transforms, camera needs to be renormalized
		camera_x_rot = clamp(camera_x_rot + event.relative.y * CAMERA_ROTATION_SPEED,deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX) )
		$camera_base/camera_rot.rotation.x =  camera_x_rot

	if event.is_action_pressed("quit"):
		get_tree().quit()

func _ready():
	#pre initialize orientation transform	
	orientation=$"Scene Root".global_transform
	orientation.origin = Vector3()
#	$camera_base/camera_rot/Camera.add_exception(self)
	
func _physics_process(delta):
	
	var motion_target = Vector2( 	Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
									Input.get_action_strength("move_forward") - Input.get_action_strength("move_back") )
			
	motion = motion.linear_interpolate(motion_target, MOTION_INTERPOLATE_SPEED * delta)
	
	var cam_z = - $camera_base/camera_rot/Camera.global_transform.basis.z			
	var cam_x = $camera_base/camera_rot/Camera.global_transform.basis.x
	
	cam_z.y=0
	cam_z = cam_z.normalized()
	cam_x.y=0
	cam_x = cam_x.normalized()
	
	var cam = $camera_base/camera_rot/Camera
	var ch_pos = $crosshair.rect_position + $crosshair.rect_size * 0.5
	var ray_from = cam.project_ray_origin(ch_pos)
	var ray_dir = cam.project_ray_normal(ch_pos)
	
	var current_aim = Input.is_action_pressed("aim")
	
	if (aiming != current_aim):
			aiming = current_aim
			if (aiming):
				$camera_base/animation.play("shoot")
			else:
				$camera_base/animation.play("far")
	
	# jump/air logic
	airborne_time += delta
	if (is_on_floor()):
		if (airborne_time>0.5):
			$sfx/land.play()
		airborne_time = 0
		
	var on_air = airborne_time > MIN_AIRBORNE_TIME
	
	if (not on_air and Input.is_action_just_pressed("jump")):
		velocity.y = JUMP_SPEED
		on_air = true
		$animation_tree["parameters/state/current"]=2
		$sfx/jump.play()							

	if (on_air):
		
		if (velocity.y > 0):
			$animation_tree["parameters/state/current"]=2
		else:
			$animation_tree["parameters/state/current"]=3
	elif (aiming):
		
		# change state to strafe
		$animation_tree["parameters/state/current"]=0

		#change aim according to camera rotation
				
		if (camera_x_rot >= 0): # aim up		
			$animation_tree["parameters/aim/add_amount"]=-camera_x_rot / deg2rad(CAMERA_X_ROT_MAX)
		else: # aim down
			$animation_tree["parameters/aim/add_amount"] = camera_x_rot / deg2rad(CAMERA_X_ROT_MIN)
					
		# convert orientation to quaternions for interpolating rotation
		var q_from = Quat(orientation.basis)
		var q_to = Quat( $camera_base.global_transform.basis )	
		# interpolate current rotation with desired one
		orientation.basis = Basis(q_from.slerp(q_to,delta*ROTATION_INTERPOLATE_SPEED))
			

		$animation_tree["parameters/strafe/blend_position"]=motion


		# get root motion transform
		root_motion = $animation_tree.get_root_motion_transform()		

		if (Input.is_action_just_pressed("shoot")):
			var shoot_from = $"Scene Root/Robot_Skeleton/Skeleton/gun_bone/shoot_from".global_transform.origin
			
			var shoot_target
			
			var col = get_world().direct_space_state.intersect_ray( ray_from, ray_from + ray_dir * 1000, [self] )
			if (col.empty()):
				shoot_target = ray_from + ray_dir * 1000
			else:
				shoot_target = col.position
				
			var shoot_dir = (shoot_target - shoot_from).normalized()
			
			var bullet = preload("res://Entities/Player/bullet.tscn").instance()

			get_parent().add_child(bullet)
			bullet.global_transform.origin = shoot_from
			bullet.direction = shoot_dir 	
			bullet.add_collision_exception_with(self)
			$sfx/shoot.play()							
			
	else: 
		
		var target = - cam_x * motion.x -  cam_z * motion.y
		if (target.length() > 0.001):
			var q_from = Quat(orientation.basis)
			var q_to = Quat(Transform().looking_at(target,Vector3(0,1,0)).basis)
	
			# interpolate current rotation with desired one
			orientation.basis = Basis(q_from.slerp(q_to,delta*ROTATION_INTERPOLATE_SPEED))
		
		#aim to zero (no aiming while walking
		
		$animation_tree["parameters/aim/add_amount"]=0
		# change state to walk
		$animation_tree["parameters/state/current"]=1
		# blend position for walk speed based on motion
		$animation_tree["parameters/walk/blend_position"]=Vector2(motion.length(),0 ) 
		
		# get root motion transform
		root_motion = $animation_tree.get_root_motion_transform()		
		
	
	# apply root motion to orientation
	orientation *= root_motion
	
	var h_velocity = orientation.origin / delta
	velocity.x = h_velocity.x
	velocity.z = h_velocity.z		
	velocity += GRAVITY * delta
	velocity = move_and_slide(velocity,Vector3(0,1,0))

	orientation.origin = Vector3() #clear accumulated root motion displacement (was applied to speed)
	orientation = orientation.orthonormalized() # orthonormalize orientation
	
	$"Scene Root".global_transform.basis = orientation.basis
	$"Scene Root".set_scale(Vector3(0.85,0.85,0.85))
	
	tps_camera_collision_response(cam, ray_dir)
	
func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# TPS camera, this avoids going through walls when rotating the camera
# Works normally, however when aiming the camera may glitch out and/or go through the wall
# TODO: needs fixing
func tps_camera_collision_response(cam, ray_dir):
	var from = cam_origin.get_translation()
	var end = cam_end.get_translation()
	var dist = from.distance_to(end)
	
	var global_from = cam_origin.get_global_transform().origin
	var global_origin = $"camera_base".get_global_transform().origin
	var test_dir = global_from - global_origin
	var offset_col = get_world().direct_space_state.intersect_ray( global_origin, global_origin + test_dir, [self] )
	if offset_col.empty():
		var col = get_world().direct_space_state.intersect_ray( global_from, global_from + (ray_dir * -dist), [self] )
		if col.empty():
			var dest = end
			cam.set_translation(cam.get_translation().linear_interpolate(end, 0.5))
			#cam.set_translation($camera_base.get_global_transform().origin - (ray_from + ray_dir * -3))
		else:
			var dist_to_origin = clamp(col.position.distance_to(global_from) - 0.2, 0, dist)
			
			var line = (end - from).normalized()
			var dest = from + (line * dist_to_origin) #+ (col.normal * 0.5) #Vector3(0, (move_back / -camera_distance) * camera_height, move_back)
			cam.set_translation(cam.get_translation().linear_interpolate(dest, 0.5))
			#cam.set_translation($camera_base.get_global_transform().origin - (col.position))
	else:
		var offset = cam_origin.get_translation().x
		var dist_to_offset = -offset - global_origin.distance_to(offset_col.position)
		var line = (global_from - global_origin).normalized()
		#from = from - (line * dist_to_origin) 
		#global_from = global_origin
		print("bruh", dist_to_offset)
		
		dist = from.distance_to(end)
		var col = get_world().direct_space_state.intersect_ray( global_from, global_from + (ray_dir * -(dist + 0.2)), [self] )
		if col.empty():
			var dest = end + (Vector3(1,0,0) * (dist_to_offset+0.2)) #+ Vector3(0.7,0,0)
			cam.set_translation(cam.get_translation().linear_interpolate(dest, 0.5))
			#cam.set_translation($camera_base.get_global_transform().origin - (ray_from + ray_dir * -3))
		else:
			var dist_to_origin = clamp(col.position.distance_to(global_from) - 0.2, 0, dist)

			line = (end - from).normalized()
			var dest = from + (line * dist_to_origin) + Vector3(0.7,0,0)
			cam.set_translation(cam.get_translation().linear_interpolate(dest, 0.5))
			#cam.set_translation($camera_base.get_global_transform().origin - (col.position))
		#cam.set_translation(cam.get_translation().linear_interpolate(dest, 0.5))
#




#		global_from = from + global_origin
#		var plane = Plane(offset_col.normal, from.length())
#		var col = plane.intersects_ray(-from, end - from)
#		print("bruh", dist_to_origin)
#		if col != null:
#			print("yea")
#			var dest = col
#			cam.set_translation(cam.get_translation().linear_interpolate(dest, 0.5))
#		else: 
#			col = plane.intersects_ray(from, end - from)
#			if col != null:
#				print("yea")
#				var dest = col
#				cam.set_translation(cam.get_translation().linear_interpolate(dest, 0.5))
		
		
		
		
		
		#dist = from.distance_to(end)
		#var col = get_world().direct_space_state.intersect_ray( global_from, global_from + (ray_dir * -dist), [self] )
		#if col.empty():
#			var dest = end
#			cam.set_translation(cam.get_translation().linear_interpolate(end, 0.5))
#			#cam.set_translation($camera_base.get_global_transform().origin - (ray_from + ray_dir * -3))
#		else:
#			print("bruh")
#			dist_to_origin = clamp(col.position.distance_to(global_from) - 0.2, 0, dist)
#
#			line = (end - from).normalized()
#			var dest = from + (line * dist_to_origin) #+ (col.normal * 0.5) #Vector3(0, (move_back / -camera_distance) * camera_height, move_back)
#			cam.set_translation(cam.get_translation().linear_interpolate(dest, 0.5))
			#cam.set_translation($camera_base.get_global_transform().origin - (col.position))
		#cam.set_translation(cam.get_translation().linear_interpolate(dest, 0.5))