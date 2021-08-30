extends KinematicBody

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	$CoM.rotate_x(delta*2.0)

func _physics_process(delta):
	if $RayCast.is_colliding():
		rotate_y(100 + (randi() % 120))
		print("colliding")
	
	if not $GroundRayCast.is_colliding():
		rotate_y(100 + (randi() % 120))
		print("no ground")
		
	move_and_slide_with_snap(global_transform.basis.z * Vector3(1, 0, 1), Vector3(0, -0.1, 0), Vector3(0, 1, 0))
