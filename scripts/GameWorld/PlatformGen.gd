extends Node

onready var grass_mat = load("res://res/materials/grass.tres") # Grass Texture

var quad_indices = [0, 1, 3, 1, 2, 3] # Magic array 
func _createPlatQuadMesh(start : Vector2, end : Vector2, 
	surface_tool : SurfaceTool, wall_vertices : Array, sIndex: int) -> void:
	
	# Normal needs to be added before the vertex for some reason (TODO: Clean up)
	var normal = (wall_vertices[2] - wall_vertices[1]).cross(wall_vertices[3] - wall_vertices[1]).normalized()
	
	# Add Vertices
	surface_tool.add_uv(Vector2(wall_vertices[0].x * 1 * WorldConstants.TEXTURE_SIZE,  
	                            wall_vertices[0].z * 1 * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[0])
	
	surface_tool.add_uv(Vector2(wall_vertices[3].x * 1 * WorldConstants.TEXTURE_SIZE,  
	                            wall_vertices[3].z * 1 * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[3])
	
	surface_tool.add_uv(Vector2(wall_vertices[2].x * 1 * WorldConstants.TEXTURE_SIZE,  
	                            wall_vertices[2].z * 1 * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[2])
	
	surface_tool.add_uv(Vector2(wall_vertices[1].x * 1 * WorldConstants.TEXTURE_SIZE,  
	                            wall_vertices[1].z * 1 * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[1])
	
	# Quad Indices
	for idx in quad_indices:
		surface_tool.add_index(sIndex + idx)

func buildPlatform(start : Vector2, meshRef : MeshInstance) -> void:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var height = 0
	var end = Vector2(start.x + 2, start.y + 2)
	
	# Calculate wall vertices
	var plat_vertices = []
	plat_vertices.insert(0, Vector3(start.x, height, start.y))
	plat_vertices.insert(1, Vector3(end.x,   height, start.y))
	plat_vertices.insert(2, Vector3(end.x,   height, end.y))
	plat_vertices.insert(3, Vector3(start.x, height, end.y))
	_createPlatQuadMesh(start, end, surface_tool, plat_vertices, 0)
	
	# Rearrange vertices for the backwall
	var bVertices = [plat_vertices[3], plat_vertices[2], plat_vertices[1], plat_vertices[0]]
	_createPlatQuadMesh(start, end, surface_tool, bVertices, 4)
	
	surface_tool.set_material(grass_mat)
	meshRef.mesh = surface_tool.commit()