extends MeshInstance

onready var EditorGUI = get_node("../GUI")

func _ready():
	mesh = generate_grid_mesh(20, 20, 1, 1, 0).commit()
	EditorGUI.get_node("MapLevel").connect("s_changeLevel", self, "on_level_change")

func on_level_change(level):
	var height = WorldConstants.LEVEL_HEIGHT * (level - 1)
	mesh = generate_grid_mesh(20, 20, 1, 1, height).commit()

func generate_grid_mesh(num_x: int, num_y: int, space_x: float, space_y: float, height: float) -> SurfaceTool:
	var surface_tool = SurfaceTool.new()
	
	surface_tool.begin(Mesh.PRIMITIVE_LINES)
	
	var index = 0
	for x in range(0, num_x +1):
		surface_tool.add_color(Color(1, 0, 0, 1))
		surface_tool.add_vertex(Vector3(num_x * space_x, height, x * space_x))
		
		surface_tool.add_color(Color(1, 0, 0, 1));
		surface_tool.add_vertex(Vector3(0, height, x * space_x))

		surface_tool.add_index(index);
		surface_tool.add_index(index+1);
		
		index += 2
	
	for y in range(0, num_y + 1):
		surface_tool.add_color(Color(1, 0, 0, 1))
		surface_tool.add_vertex(Vector3(y * space_x, height, num_y * space_y))
		
		surface_tool.add_color(Color(1, 0, 0, 1));
		surface_tool.add_vertex(Vector3(y * space_y, height, 0))

		surface_tool.add_index(index);
		surface_tool.add_index(index+1);
		
		index += 2
	
	return surface_tool


