extends KinematicBody

var speed = 100
var hits := 1
var active := true
var dead := false

var player_nearby = null
var target_checks = 0
var invalid_checks = 0
var spin := false

func check_valid():
	if $GroundRayCast.is_colliding():
		active = true

func set_speed(speed: int):
	self.speed = speed

func _process(delta):
	if active and not spin:
		$CoM.rotate_x(delta*2.0)

func target_player():
	if player_nearby != null:
		# Get direction vector of iceman and to the player
		var player_transform = player_nearby.global_transform.origin
		player_transform = Vector3(player_transform.x, 0, player_transform.z)
		var self_transform = global_transform.origin
		self_transform = Vector3(self_transform.x, 0, self_transform.z)
		
		# Use the dot product to work out the angle between them
		var dir = (global_transform.basis.z * Vector3(1, 0, 1)).normalized()
		var dir_to_player = (player_transform - self_transform).normalized()
		var dot = dir.dot(dir_to_player)
		var angle = acos(dot)
		
		# Don't turn if iceman is directly infront of player (or nasty errors)
		if abs(angle) < 0.01 or abs(dot) > 0.99:
			return

		# Figure if the player is to the left or right to the iceman
		if dir.cross(Vector3(0, 1, 0)).dot(dir_to_player) > 0:
			rotate_y(-angle)
		else:
			rotate_y(angle)
		

var valid_movement: bool
func _physics_process(delta):
	if spin:
		rotate_y(delta * 20.0)
		return
	
	if active:
		valid_movement = true
		
		if $RayCast.is_colliding() or $RayCast2.is_colliding():
			valid_movement = false
			if player_nearby and (randi() % 2) == 0:
				target_player()
			else:
				rotate_y(100 + (randi() % 120))
				
			$HitSFX.play()
		
		if not $GroundRayCast.is_colliding():
			valid_movement = false
			if player_nearby and (randi() % 3) == 0:
				target_player()
			else:
				rotate_y(100 + (randi() % 120))
		
		if valid_movement:
			invalid_checks = 0
			move_and_slide_with_snap(global_transform.basis.z * Vector3(1, 0, 1) * delta * speed, Vector3(0, -0.1, 0), Vector3(0, 1, 0))
		else:
			invalid_checks += 1
			if invalid_checks > 15:
				active = false

func _on_NearArea_body_entered(body):
	if body.has_meta("player"):
		player_nearby = body

func _on_NearArea_body_exited(body):
	if body == player_nearby:
		player_nearby = null

func _on_ThinkTimer_timeout():
	if player_nearby != null and (randi() % 5) == 0:
		target_player()

func hit():
	self.hits -= 1
	self.spin = true
	$LoudHitSFX.play()
	
	yield(get_tree().create_timer(0.7), "timeout")
	self.spin = false

func _on_HitBox_body_entered(body):
	if body.has_meta("type") and not spin: # Invulnerable while spinning?
		if body.get_meta("type") == "projectile" and body.has_method("get_p_owner") and not dead:
			if self.hits > 1:
				hit()
				body.explode(body.global_transform.origin, false)
				return
			
			dead = true
			var player = body.get_p_owner()
			if player != null:
				var gui = player.get_node_or_null("PlayerGUI")
				if gui != null:
					gui.call("killedIceman")
			
			body.explode(body.global_transform.origin, false)
			
			# Explode
			var split = preload("res://Entities/Legacy/Iceman/Iceman_split.tscn").instance()
			split.global_transform = self.global_transform
			get_parent().add_child(split)
			
			# Let the level manager know
			var level_manager = get_parent().get_parent()
			level_manager.call("player_collect", "iceman")
			
			# Disappear & Clean up
			self.visible = false
			self.active = false
			self.queue_free()
	
	if body.has_meta("player"):
		if not body.invulnerable:
			body.call("freeze")

func set_hits(hits: int):
	self.hits = hits
