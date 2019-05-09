extends MeshInstance

func _ready():
	var surface_tool = SurfaceTool.new();
	
	surface_tool.begin(Mesh.PRIMITIVE_LINE_LOOP);
	
	surface_tool.add_normal(Vector3(0, 0, -1));
	surface_tool.add_color(Color(0, 0, 0, 1));
	surface_tool.add_vertex(Vector3(-1, 2, 1));
	
	surface_tool.add_normal(Vector3(0, 0, -1));
	surface_tool.add_color(Color(1, 0, 0, 1));
	surface_tool.add_vertex(Vector3(-1, 0, -1));
	
	surface_tool.add_normal(Vector3(0, 0, -1));
	surface_tool.add_color(Color(1, 0, 0, 1));
	surface_tool.add_vertex(Vector3(1, 0, -1));
	
	surface_tool.add_normal(Vector3(0, 0, -1));
	surface_tool.add_color(Color(0, 0, 0, 1));
	surface_tool.add_vertex(Vector3(1, 2, 1));

	surface_tool.add_index(0);
	surface_tool.add_index(1);
	surface_tool.add_index(2);
	
	surface_tool.add_index(0);
	surface_tool.add_index(2);
	surface_tool.add_index(3);
	
	mesh = surface_tool.commit();

