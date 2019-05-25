extends Spatial

onready var camera = get_node("../EditorCamera/Camera")

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
		
		wall = MeshInstance.new()
		get_node("../World").add_child(wall)
		wall.set_owner(get_node(".."))
	
	if Input.is_action_pressed("editor_place"):
		placement_end = grid_pos
		
		if placement_start != placement_end:
			buildWall(wall)
	
	if Input.is_action_just_released("editor_place"):
		pass
	
	mouse_motion = Vector2()

func _input(event: InputEvent) -> void:
	# Mouse movement
	if event is InputEventMouseMotion:
		mouse_motion = event.relative

var quad_indices = [0, 1, 3, 1, 2, 3] # Magic array 
func createQuadMesh(surface_tool : SurfaceTool, wall_vertices : Array, sIndex: int) -> void:
	# Normal needs to be added before the vertex for some reason (TODO: Clean up)
	var normal = (wall_vertices[2] - wall_vertices[1]).cross(wall_vertices[3] - wall_vertices[1]).normalized()
	
	# Add Vertices
	
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[0])
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[3])
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[2])
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[1])
	
	# Add Normal
	#for x in range(0, 4):
	#	surface_tool.add_normal(normal)
	
	# Quad Indices
	for idx in quad_indices:
		surface_tool.add_index(sIndex + idx)

func buildWall(meshRef : MeshInstance) -> void:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var minHeight = 0
	var maxHeight = 2
	
	# Calculate wall vertices
	var wall_vertices = []
	wall_vertices.insert(0, Vector3(placement_start.x, minHeight, placement_start.y))
	wall_vertices.insert(1, Vector3(placement_start.x,  maxHeight, placement_start.y))
	wall_vertices.insert(2, Vector3(placement_end.x, maxHeight, placement_end.y))
	wall_vertices.insert(3, Vector3(placement_end.x, minHeight, placement_end.y))
	createQuadMesh(surface_tool, wall_vertices, 0)
	
	# Rearrange vertices for the backwall
	var bVertices = [wall_vertices[3], wall_vertices[2], wall_vertices[1], wall_vertices[0]]
	createQuadMesh(surface_tool, bVertices, 4)
	
	meshRef.mesh = surface_tool.commit()
