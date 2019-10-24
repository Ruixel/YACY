extends MeshInstance

onready var EditorGUI = get_node("../GUI")
onready var trans_grid_mat = load("res://res/materials/grid_transparent.tres")

func _ready():
	mesh = generate_grid_mesh(80, 80, 1, 1, 0).commit()
	$TransparentGround.mesh = generate_trans_ground(80, 80, 1, 1, 0).commit()
	EditorGUI.get_node("MapLevel").connect("s_changeLevel", self, "on_level_change")
	EditorGUI.get_node("Misc").connect("s_toggleGrid", self, "on_toggle_grid")

func on_level_change(level):
	var height = WorldConstants.LEVEL_HEIGHT * (level - 1)
	mesh = generate_grid_mesh(80, 80, 1, 1, height).commit()
	$TransparentGround.mesh = generate_trans_ground(80, 80, 1, 1, height).commit()

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

const quad_indices = [0, 1, 3, 0, 3, 2]
func generate_trans_ground(num_x: int, num_y: int, space_x: float, space_y: float, height: float) -> SurfaceTool:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	surface_tool.add_vertex(Vector3(0, height - 0.03, 0))
	surface_tool.add_vertex(Vector3(num_x * space_x, height - 0.03, 0))
	surface_tool.add_vertex(Vector3(0, height - 0.03, num_y * space_y))
	surface_tool.add_vertex(Vector3(num_x * space_x, height - 0.03, num_y * space_y))
	
	for i in quad_indices:
		surface_tool.add_index(i)
		
	surface_tool.set_material(trans_grid_mat)
	
	return surface_tool

func on_toggle_grid(isVisible):
	set_visible(isVisible)