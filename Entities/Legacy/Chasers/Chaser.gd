extends CharacterBody3D

var player_inside = null
var active := false
var is_player_slow = false
var max_speed = 4.2
var speed = 4.2
var speed_multiplier = 1.0
var unreachable_frames = 0
var y_pos := 0.0

var id = null
var model = null
const models := {
	1: "res://Entities/Legacy/Chasers/Models/Pumpkin/Pumpkin.tscn",
	2: "res://Entities/Legacy/Chasers/Models/Saucer/Saucer.tscn",
	3: "res://Entities/Legacy/Chasers/Models/Ghost/Ghost.tscn"
}

func _ready():
	set_meta("type", "chaser")

func set_velocity(chaser_speed):
	max_speed = chaser_speed

func _physics_process(delta):
	if active and player_inside:
		if $RayCast3D.is_colliding():
			target_player()
			unreachable_frames += 1
			if unreachable_frames > 5:
				disable()
		else:
			unreachable_frames = 0
		
		if not is_player_slow:
			speed -= 0.4 * delta
		
		move_and_collide(global_transform.basis.z * Vector3(1, 0, 1) * speed * delta * speed_multiplier, false)
		self.position.y = y_pos

func disable():
	if player_inside != null:
		player_inside.deactivate_chaser(self)
		
	self.player_inside = null
	active = false
	model.get_node("SFX").stop()
	$Timer.stop()
	
	set_material_opacity(0.175)

func set_material_opacity(opacity: float):
	if model != null:
		var mesh = model.get_node_or_null("Mesh/MeshInstance3D")
		if mesh != null:
			var surfaces = mesh.mesh.get_surface_count()
			for i in range(surfaces):
				var surface = mesh.mesh.surface_get_material(i)
				var new_albedo = surface.albedo_color
				new_albedo.a = opacity
				surface.albedo_color = new_albedo
				surface.flags_transparent = opacity < 1

func set_model(model_id):
	if not models.has(model_id):
		queue_free()
		return
	
	self.id = model_id
	model = load(models.get(model_id)).instantiate()
	add_child(model)
	
	await model.ready
	var mesh = model.get_node_or_null("Mesh/MeshInstance3D")
	var surfaces = mesh.mesh.get_surface_count()
	for i in range(surfaces):
		var surface = mesh.mesh.surface_get_material(i).duplicate()
		mesh.mesh.surface_set_material(i, surface)

func check_if_player_behind_wall(player):
	var space_state = get_world_3d().direct_space_state
	var ray = space_state.intersect_ray(self.global_transform.origin, player.global_transform.origin, [player], WorldConstants.GEOMETRY_COLLISION_BIT)
	if not ray.is_empty():
		return true
	
	return false

func _on_NearArea_body_entered(body):
	if body.has_meta("player") and player_inside == null:
		if check_if_player_behind_wall(body): 
			return 
		
		active = true
		y_pos = self.position.y
		speed = max_speed
		player_inside = body
		$Timer.start()
		model.get_node("SFX").play()
		body.activate_chaser(self)
		
		if id == 3:
			set_material_opacity(0.6)
		else: 
			set_material_opacity(1.0)
		
		target_player()

func _on_FarArea_body_exited(body):
	if body.has_meta("player") and self.player_inside == body:
		disable()

func target_player():
	if player_inside != null:
		# Get direction vector of chaser and to the player
		var player_transform = player_inside.global_transform.origin
		player_transform = Vector3(player_transform.x, 0, player_transform.z)
		var self_transform = global_transform.origin
		self_transform = Vector3(self_transform.x, 0, self_transform.z)
		
		# Use the dot product to work out the angle between them
		var dir = (global_transform.basis.z * Vector3(1, 0, 1)).normalized()
		var dir_to_player = (player_transform - self_transform).normalized()
		var dot = dir.dot(dir_to_player)
		var angle = acos(dot)
		
		# Don't turn if chaser is directly infront of player (or nasty errors)
		if abs(angle) < 0.01 or abs(dot) > 0.99:
			var test = self_transform + (dir * 0.2)
			if self_transform.distance_to(player_transform) < test.distance_to(player_transform):
				rotate_y(deg_to_rad(180.0))
				
			return

		# Figure if the player is to the left or right to the chaser
		if dir.cross(Vector3(0, 1, 0)).dot(dir_to_player) > 0:
			rotate_y(-angle)
		else:
			rotate_y(angle)

func _on_Timer_timeout():
	target_player()

func _on_SlowArea_body_entered(body):
	if body.has_meta("player"):
		body.chaser_triggered(self)
		
		speed = max_speed
		is_player_slow = true

func _on_SlowArea_body_exited(body):
	if body.has_meta("player"):
		body.chaser_untriggered(self)
		
		is_player_slow = false

func slow_down():
	speed_multiplier = 0.5
	$CrumbTimer.start()

func _on_CrumbTimer_timeout():
	speed_multiplier = 1.0
