extends KinematicBody

var speed = 100
var active := true

func check_valid():
	if $GroundRayCast.is_colliding():
		active = true

func set_speed(speed: int):
	self.speed = speed

func _process(delta):
	$CoM.rotate_x(delta*2.0)

func _physics_process(delta):
	if active:
		if $RayCast.is_colliding() or $RayCast2.is_colliding():
			rotate_y(100 + (randi() % 120))
			$HitSFX.play()
		
		if not $GroundRayCast.is_colliding():
			rotate_y(100 + (randi() % 120))
			
		move_and_slide_with_snap(global_transform.basis.z * Vector3(1, 0, 1) * delta * speed, Vector3(0, -0.1, 0), Vector3(0, 1, 0))
