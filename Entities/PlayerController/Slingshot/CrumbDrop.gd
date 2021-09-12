extends KinematicBody

var velocity = Vector3(0, -1, 0)

#func _physics_process(delta):
#	if is_on_floor():
#		move_and_slide(velocity, Vector3(0, 1, 0))
#		set_physics_process(false) # Don't waste CPU cycles 
#	else:
#		velocity.y -= 18 * delta
#		move_and_slide(velocity, Vector3(0, 1, 0))

func _physics_process(delta):
	var velocity = Vector3(0, -1, 0) * delta * 6
	
	var collision_data = move_and_collide(velocity)
	if collision_data != null:
		$ChaserTrap/CollisionShape.disabled = false
		set_physics_process(false)


func _on_ChaserTrap_body_entered(body):
	if body.has_meta("type") and body.get_meta("type") == "chaser":
		body.slow_down()
