extends Spatial

onready var camera = get_node("../EditorCamera/Camera")
onready var WorldAPI = get_node("../WorldInterface")

var mouse_motion = Vector2()

var grid_plane = Plane(Vector3(0,-1,0), 0.0)
var grid_spacing = 1
var grid_num = 20
var grid_pos = Vector2()

var placement_start = Vector2()
var placement_end = Vector2()

var wall

func _process(delta: float) -> void:
	if mouse_motion != Vector2():
		# Cast ray directly from camera
		var ray_origin = camera.get_camera_transform().origin
		var ray_direction = camera.project_ray_normal(get_viewport().get_mouse_position()).normalized()
		
		# If it intersects with the grid, place the cursor on the new position
		var grid_intersection = grid_plane.intersects_ray(ray_origin, ray_direction)
		if grid_intersection != null:
			# Calculate nearest grid edge
			grid_pos.x = clamp(round(grid_intersection.x / grid_spacing), 0, grid_num)
			grid_pos.y = clamp(round(grid_intersection.z / grid_spacing), 0, grid_num)
			
			self.transform.origin = Vector3(grid_pos.x * grid_spacing, 0, grid_pos.y * grid_spacing)
	
	if Input.is_action_just_pressed("editor_place"):
		placement_start = grid_pos
		
		WorldAPI.selection_create()
	
	if Input.is_action_pressed("editor_place"):
		placement_end = grid_pos
		
		if placement_start != placement_end:
			WorldAPI.selection_buildWall(placement_start, placement_end)
	
	if Input.is_action_just_released("editor_place"):
		pass
	
	mouse_motion = Vector2()

func _input(event: InputEvent) -> void:
	# Mouse movement
	if event is InputEventMouseMotion:
		mouse_motion = event.relative

