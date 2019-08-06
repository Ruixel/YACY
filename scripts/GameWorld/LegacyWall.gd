extends Node

var start : Vector2
var end : Vector2 = Vector2(-1, -1) # Invalid vector
var level : int

var texture : int = 4

var max_height : float = 1.0
var min_height : float = 0.0
const max_height_list = [4, 3, 2, 1, 2, 3, 4, 4, 4, 3]
const min_height_list = [0, 0, 0, 0, 1, 2, 3, 2, 1, 1]

var mesh : MeshInstance
var selection_mesh : MeshInstance 
var collision_mesh : StaticBody
var collision_shape : CollisionShape

func _init(parent, position : Vector2, lvl : int):
	mesh = MeshInstance.new()
	collision_mesh = StaticBody.new()
	collision_shape = CollisionShape.new()
	
	start = position
	level = lvl
	
	add_child(mesh)
	add_child(collision_mesh)
	collision_mesh.add_child(collision_shape)
	
	parent.add_child(self)

func get_type():
	return "wall"

func change_end_pos(pos : Vector2):
	end = pos
	_genMesh()

func change_height_value(h : int):
	max_height = max_height_list[h - 1] / 4.0
	min_height = min_height_list[h - 1] / 4.0

	_genMesh()

func change_texture(index: int):
	texture = index
	_genMesh()

func _genMesh():
	mesh.mesh = buildWall(start, end, level, min_height, max_height, texture)
	collision_shape.shape = mesh.mesh.create_convex_shape()

func selectObj():
	selection_mesh = MeshInstance.new()
	selection_mesh.mesh = buildWallSelectionMesh(start, end, level, min_height, max_height, 0.05)

# Static Mesh Creation Functions

# Single face
const quad_indices = [0, 1, 3, 1, 2, 3] # Magic array 
static func _createWallQuadMesh(start : Vector2, end : Vector2, 
	surface_tool : SurfaceTool, wall_vertices : Array, sIndex: int, tex : int) -> void:
	
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

# Build Mesh
static func buildWall(start : Vector2, end : Vector2, level : int, min_height : float, 
	max_height : float, tex : int) -> Mesh:
	
	# Only create mesh for valid walls
	if end.x == -1:
		return Mesh.new()
	
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var minHeight = (level - 1 + max_height) * WorldConstants.LEVEL_HEIGHT
	var maxHeight = (level - 1 + min_height) * WorldConstants.LEVEL_HEIGHT
	
	# Calculate wall vertices
	var wall_vertices = []
	wall_vertices.insert(0, Vector3(start.x, minHeight, start.y))
	wall_vertices.insert(1, Vector3(start.x, maxHeight, start.y))
	wall_vertices.insert(2, Vector3(end.x, maxHeight, end.y))
	wall_vertices.insert(3, Vector3(end.x, minHeight, end.y))
	_createWallQuadMesh(start, end, surface_tool, wall_vertices, 0, tex)
	
	# Rearrange vertices for the backwall
	var bVertices = [wall_vertices[3], wall_vertices[2], wall_vertices[1], wall_vertices[0]]
	_createWallQuadMesh(start, end, surface_tool, bVertices, 4, tex)
	
	surface_tool.set_material(WorldTextures.aTexture_mat)
	return surface_tool.commit()

func buildWallSelectionMesh(start : Vector2, end : Vector2, level : int, min_height : float, max_height : float,
	outlineWidth : float) -> Mesh:
	
	# Only create mesh for valid walls
	if end.x == -1:
		return Mesh.new()
		
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var minHeight = (level - 1 + max_height) * WorldConstants.LEVEL_HEIGHT + outlineWidth
	var maxHeight = (level - 1 + min_height) * WorldConstants.LEVEL_HEIGHT - outlineWidth
	
	# Get Vector 
	var wall_vec = (end - start).normalized()
	end   = end   + wall_vec * outlineWidth
	start = start - wall_vec * outlineWidth
	
	var normal_vec = Vector3(wall_vec.x, 0, wall_vec.y).cross(Vector3(0, 1, 0))
	
	var wall_vertices = []
	wall_vertices.insert(0, Vector3(start.x, minHeight, start.y))
	wall_vertices.insert(1, Vector3(start.x, maxHeight, start.y))
	wall_vertices.insert(2, Vector3(end.x, maxHeight, end.y))
	wall_vertices.insert(3, Vector3(end.x, minHeight, end.y))
	
	var new_vertices = []
	for vertex in wall_vertices:
		new_vertices.append(vertex - normal_vec * 0.02)
	
	_createWallQuadMesh(start, end, surface_tool, new_vertices, 0, 1)
	
	var bVertices = [wall_vertices[3], wall_vertices[2], wall_vertices[1], wall_vertices[0]]
	var new_bVertices = []
	for vertex in bVertices:
		new_bVertices.append(vertex + normal_vec * 0.02)
	_createWallQuadMesh(start, end, surface_tool, new_bVertices, 4, 1)
	
	surface_tool.set_material(WorldTextures.selection_mat)
	return surface_tool.commit()