extends KinematicBody

var velocity = Vector3(0, -1, 0)

func _physics_process(delta):
	if is_on_floor():
		move_and_slide(velocity, Vector3(0, 1, 0))
		set_physics_process(false) # Don't waste CPU cycles 
	else:
		velocity.y -= 18 * delta
		move_and_slide(velocity, Vector3(0, 1, 0))
