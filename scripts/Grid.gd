extends MeshInstance

func generate_grid_mesh(num_x: int, num_y: int, space_x: float, space_y: float) -> SurfaceTool:
	var surface_tool = SurfaceTool.new()
	
	surface_tool.begin(Mesh.PRIMITIVE_LINES)
	
	var index = 0
	for x in range(0, num_x +1):
		surface_tool.add_color(Color(1, 0, 0, 1))
		surface_tool.add_vertex(Vector3(num_x * space_x, 0, x * space_x))
		
		surface_tool.add_color(Color(1, 0, 0, 1));
		surface_tool.add_vertex(Vector3(0, 0, x * space_x))

		surface_tool.add_index(index);
		surface_tool.add_index(index+1);
		
		index += 2
	
	for y in range(0, num_y + 1):
		surface_tool.add_color(Color(1, 0, 0, 1))
		surface_tool.add_vertex(Vector3(y * space_x, 0, num_y * space_y))
		
		surface_tool.add_color(Color(1, 0, 0, 1));
		surface_tool.add_vertex(Vector3(y * space_y, 0, 0))

		surface_tool.add_index(index);
		surface_tool.add_index(index+1);
		
		index += 2
	
	return surface_tool

func _ready():
	mesh = generate_grid_mesh(20, 20, 1, 1).commit()

