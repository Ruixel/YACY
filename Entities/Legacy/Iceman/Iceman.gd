extends KinematicBody

var speed = 100
var active := true

var player_nearby = null
var target_checks = 0

func check_valid():
	if $GroundRayCast.is_colliding():
		active = true

func set_speed(speed: int):
	self.speed = speed

func _process(delta):
	$CoM.rotate_x(delta*2.0)

func target_player():
	if player_nearby != null:
		print("targeting")
		var player_transform = player_nearby.global_transform.origin
		player_transform = Vector3(player_transform.x, 0, player_transform.z)
		var self_transform = global_transform.origin
		self_transform = Vector3(self_transform.x, 0, self_transform.z)
		
		var dir = (global_transform.basis.z * Vector3(1, 0, 1)).normalized()
		var dir_to_player = (player_transform - self_transform).normalized()
		var dot = dir.dot(dir_to_player)
		var angle = acos(dot)

		if abs(angle) > 0.01 and dir.cross(Vector3(0, 1, 0)).dot(dir_to_player) > 0:
			rotate_y(-angle)
		else:
			rotate_y(angle)

func _physics_process(delta):
	if active:
		if $RayCast.is_colliding() or $RayCast2.is_colliding():
			if player_nearby and (randi() % 2) == 0:
				target_player()
			else:
				rotate_y(100 + (randi() % 120))
				
			$HitSFX.play()
		
		if not $GroundRayCast.is_colliding():
			if player_nearby and (randi() % 3) == 0:
				target_player()
			else:
				rotate_y(100 + (randi() % 120))
			
		move_and_slide_with_snap(global_transform.basis.z * Vector3(1, 0, 1) * delta * speed, Vector3(0, -0.1, 0), Vector3(0, 1, 0))

func _on_NearArea_body_entered(body):
	if body.name == "Player":
		player_nearby = body

func _on_NearArea_body_exited(body):
	if body == player_nearby:
		player_nearby = null

func _on_ThinkTimer_timeout():
	if player_nearby != null and (randi() % 5) == 0:
		target_player()
