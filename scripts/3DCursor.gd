extends Spatial

onready var camera = get_node("../EditorCamera/Camera")

var mouse_motion = Vector2()

var grid_plane = Plane(Vector3(0,-1,0), 0.0)

func _process(delta: float) -> void:
	if mouse_motion != Vector2():
		# Cast ray directly from camera
		var ray_origin = camera.get_camera_transform().origin
		var ray_direction = camera.project_ray_normal(get_viewport().get_mouse_position()).normalized()
		
		# If it intersects with the grid, place the cursor on the new position
		var grid_intersection = grid_plane.intersects_ray(ray_origin, ray_direction)
		if grid_intersection != null:
			self.transform.origin = grid_intersection
	
	mouse_motion = Vector2()

func _input(event: InputEvent) -> void:
	# Mouse movement
	if event is InputEventMouseMotion:
		mouse_motion = event.relative

