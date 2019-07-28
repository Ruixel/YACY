extends Node

onready var aTexture_mat = load("res://res/materials/ArrayTexture.tres")

var start : Vector2
var end : Vector2

var texture : int = 4
var level : int
var thickness : float = 0.1

var max_height : float = 1.0
var min_height : float = 0.0
const max_height_list = [4, 3, 2, 1, 2, 3, 4, 4, 4, 3]
const min_height_list = [0, 0, 0, 0, 1, 2, 3, 2, 1, 1]

var mesh : MeshInstance
var selection_mesh : MeshInstance 
var collision_mesh : StaticBody
var collision_shape : CollisionShape

var meshGenObj
func _init(parent, meshGen):
	mesh = MeshInstance.new()
	collision_mesh = StaticBody.new()
	collision_shape = CollisionShape.new()
	
	add_child(mesh)
	add_child(collision_mesh)
	collision_mesh.add_child(collision_shape)
	
	meshGenObj = meshGen
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
	mesh.mesh = buildMesh()
	collision_shape.shape = mesh.mesh.create_convex_shape()

func selectObj():
	selection_mesh = MeshInstance.new()
	selection_mesh.mesh = meshGenObj.buildWallSelectionMesh(start, end, level, min_height, max_height, 0.05)

func buildMesh() -> Mesh:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var minHeight = (level - 1 + max_height) * WorldConstants.LEVEL_HEIGHT
	var maxHeight = (level - 1 + min_height) * WorldConstants.LEVEL_HEIGHT
	
	# Get Normal Vector 
	var wall_vec   = (end - start).normalized()
	var wall_end   = end   + wall_vec * thickness
	var wall_start = start - wall_vec * thickness
	
	var normal_vec = Vector3(wall_vec.x, 0, wall_vec.y).cross(Vector3(0, 1, 0))
	
	# Calculate wall vertices
	var quad_vertices = []
	quad_vertices.insert(0, Vector3(wall_end.x, maxHeight, wall_end.y)     - normal_vec * thickness)
	quad_vertices.insert(1, Vector3(wall_start.x, maxHeight, wall_start.y) - normal_vec * thickness)
	quad_vertices.insert(2, Vector3(wall_start.x, minHeight, wall_start.y) - normal_vec * thickness)
	quad_vertices.insert(3, Vector3(wall_end.x, minHeight, wall_end.y)     - normal_vec * thickness)
	
	quad_vertices.insert(4, Vector3(wall_end.x, maxHeight, wall_end.y)     + normal_vec * thickness)
	quad_vertices.insert(5, Vector3(wall_start.x, maxHeight, wall_start.y) + normal_vec * thickness)
	quad_vertices.insert(6, Vector3(wall_start.x, minHeight, wall_start.y) + normal_vec * thickness)
	quad_vertices.insert(7, Vector3(wall_end.x, minHeight, wall_end.y)     + normal_vec * thickness)
	_createWallQuadMesh(quad_vertices[4], quad_vertices[5], quad_vertices[6], quad_vertices[7], surface_tool, 0)
	_createWallQuadMesh(quad_vertices[0], quad_vertices[3], quad_vertices[2], quad_vertices[1], surface_tool, 4)
	
	_createWallQuadMesh(quad_vertices[2], quad_vertices[3], quad_vertices[7], quad_vertices[6], surface_tool, 8)
	_createWallQuadMesh(quad_vertices[1], quad_vertices[5], quad_vertices[4], quad_vertices[0], surface_tool, 12)
	
	_createWallQuadMesh(quad_vertices[0], quad_vertices[4], quad_vertices[7], quad_vertices[3], surface_tool, 16)
	_createWallQuadMesh(quad_vertices[1], quad_vertices[2], quad_vertices[6], quad_vertices[5], surface_tool, 20)
	
	surface_tool.set_material(aTexture_mat)
	return surface_tool.commit()

var quad_indices = [0, 1, 2, 0, 2, 3] # Magic array 
func _createWallQuadMesh(v1 : Vector3, v2 : Vector3, v3 : Vector3, v4 : Vector3, 
	surface_tool : SurfaceTool, sIndex: int) -> void:
	
	# Normal needs to be added before the vertex for some reason (TODO: Clean up)
	var normal = (v1 - v2).cross(v3 - v2).normalized()
	
	# Texture constants
	var wall_length = sqrt(pow(end.y - start.y, 2) + pow(end.x - start.x, 2))
	# Godot does not allow for custom vertex attributes, use the alpha in Color() for storing texture index
	var texture_float = (texture+1.0)/256
	var texture_scale = WorldTextures.textures[texture].texScale
	
	var dir = normal.cross(Vector3(0, 1, 0))
	
	# Add Vertices
	surface_tool.add_color(Color(1, 1, 1, texture_float))
	surface_tool.add_normal(normal)
	surface_tool.add_uv(Vector2((dir.x * v1.x + dir.z * v1.z) * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
	                            -v1.y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_vertex(v1)
	
	surface_tool.add_color(Color(1, 1, 1, texture_float))
	surface_tool.add_normal(normal)
	surface_tool.add_uv(Vector2((dir.x * v2.x + dir.z * v2.z) * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
	                            -v2.y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_vertex(v2)
	
	surface_tool.add_color(Color(1, 1, 1, texture_float))
	surface_tool.add_normal(normal)
	surface_tool.add_uv(Vector2((dir.x * v3.x + dir.z * v3.z) * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
	                            -v3.y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_vertex(v3)
	
	surface_tool.add_color(Color(1, 1, 1, texture_float))
	surface_tool.add_normal(normal)
	surface_tool.add_uv(Vector2((dir.x * v4.x + dir.z * v4.z) * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
	                            -v4.y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_vertex(v4)
	
	# Quad Indices
	for idx in quad_indices:
		surface_tool.add_index(sIndex + idx)