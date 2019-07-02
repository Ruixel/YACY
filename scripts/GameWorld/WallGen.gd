extends Node

onready var brick_mat = load("res://res/materials/brickwall.tres") # Brick Texture
onready var aTexture_mat = load("res://res/materials/ArrayTexture.tres")

var tex : int = 15

var quad_indices = [0, 1, 3, 1, 2, 3] # Magic array 
func _createWallQuadMesh(start : Vector2, end : Vector2, 
	surface_tool : SurfaceTool, wall_vertices : Array, sIndex: int) -> void:
	
	# Normal needs to be added before the vertex for some reason (TODO: Clean up)
	var normal = (wall_vertices[2] - wall_vertices[1]).cross(wall_vertices[3] - wall_vertices[1]).normalized()
	
	# Texture constants
	var wall_length = sqrt(pow(end.y - start.y, 2) + pow(end.x - start.x, 2))
	# Godot does not allow for custom vertex attributes, use the alpha in Color() for storing texture index
	var texture_float = (tex+1.0)/256
	var texture_scale = WorldTextures.textures[tex].texScale
	
	# Add Vertices
	surface_tool.add_color(Color(1, 1, 1, texture_float))
	surface_tool.add_uv(Vector2(0 * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
	                            wall_vertices[2].y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[0])
	
	surface_tool.add_color(Color(1, 1, 1, texture_float))
	surface_tool.add_uv(Vector2(wall_length * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
	                            wall_vertices[2].y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[3])
	
	surface_tool.add_color(Color(1, 1, 1, texture_float))
	surface_tool.add_uv(Vector2(wall_length * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
	                            wall_vertices[0].y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[2])
	
	surface_tool.add_color(Color(1, 1, 1, texture_float))
	surface_tool.add_uv(Vector2(0 * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
	                            wall_vertices[0].y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[1])
	
	# Quad Indices
	for idx in quad_indices:
		surface_tool.add_index(sIndex + idx)

func buildWall(start : Vector2, end : Vector2, level : int, meshRef : MeshInstance) -> void:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var minHeight = (level - 1) * WorldConstants.LEVEL_HEIGHT
	var maxHeight = level * WorldConstants.LEVEL_HEIGHT
	
	# Calculate wall vertices
	var wall_vertices = []
	wall_vertices.insert(0, Vector3(start.x, minHeight, start.y))
	wall_vertices.insert(1, Vector3(start.x, maxHeight, start.y))
	wall_vertices.insert(2, Vector3(end.x, maxHeight, end.y))
	wall_vertices.insert(3, Vector3(end.x, minHeight, end.y))
	_createWallQuadMesh(start, end, surface_tool, wall_vertices, 0)
	
	# Rearrange vertices for the backwall
	var bVertices = [wall_vertices[3], wall_vertices[2], wall_vertices[1], wall_vertices[0]]
	_createWallQuadMesh(start, end, surface_tool, bVertices, 4)
	
	surface_tool.set_material(aTexture_mat)
	meshRef.mesh = surface_tool.commit()