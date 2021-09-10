extends KinematicBody

var player_inside = null
var active := false
var speed = 100

var id = null
var model = null
const models := {
	1: "res://Entities/Legacy/Chasers/Models/Pumpkin/Pumpkin.tscn",
	2: "res://Entities/Legacy/Chasers/Models/Saucer/Saucer.tscn",
	3: "res://Entities/Legacy/Chasers/Models/Ghost/Ghost.tscn"
}

func _physics_process(delta):
	if player_inside:
		target_player()
		move_and_slide_with_snap(global_transform.basis.z * Vector3(1, 0, 1) * delta * speed, Vector3(0, -0.1, 0), Vector3(0, 1, 0))

func set_material_opacity(opacity: float):
	if model != null:
		var mesh = model.get_node_or_null("Mesh/MeshInstance")
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
	model = load(models.get(model_id)).instance()
	add_child(model)
	
	yield(model, "ready")
	var mesh = model.get_node_or_null("Mesh/MeshInstance")
	var surfaces = mesh.mesh.get_surface_count()
	for i in range(surfaces):
		var surface = mesh.mesh.surface_get_material(i).duplicate()
		mesh.mesh.surface_set_material(i, surface)

func _on_NearArea_body_entered(body):
	if body.has_meta("player"):
		self.player_inside = body
		target_player()
		active = true
		
		if id == 3:
			set_material_opacity(0.6)
		else: 
			set_material_opacity(1.0)

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
			return

		# Figure if the player is to the left or right to the chaser
		if dir.cross(Vector3(0, 1, 0)).dot(dir_to_player) > 0:
			rotate_y(-angle)
		else:
			rotate_y(angle)
