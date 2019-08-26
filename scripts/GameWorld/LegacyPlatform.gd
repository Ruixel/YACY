extends Node
const toolType = WorldConstants.Tools.PLATFORM

var pos : Vector2
var level : int

var texture : int = 1
var colour := Color(1, 1, 1)

onready var selection_mat = load("res://res/materials/selection.tres")
var prototype_grass_mat 

var height_offset : float = 0.0
const h_offset_list = [0, 1, 2, 3]

var mesh : MeshInstance
var selection_mesh : MeshInstance
var collision_mesh : StaticBody
var collision_shape : CollisionShape

var meshGenObj
func _init(parent, position : Vector2, lvl : int):
	mesh = MeshInstance.new()
	collision_mesh = StaticBody.new()
	collision_shape = CollisionShape.new()
	
	pos = position
	level = lvl 
	
	add_child(mesh)
	add_child(collision_mesh)
	collision_mesh.add_child(collision_shape)
	
	parent.add_child(self)

func change_height_value(h : int):
	if h <= 4:
		height_offset = h_offset_list[h-1] / 4.0
	
	_genMesh()

func change_texture(index: int):
	texture = index
	_genMesh()

func change_colour(newColour : Color):
	colour = newColour
	_genMesh()

func _genMesh():
	mesh.mesh = buildPlatform(pos, level, height_offset, texture, colour, false)
	collision_shape.shape = mesh.mesh.create_convex_shape()

func selectObj():
	selection_mesh = MeshInstance.new()
	selection_mesh.mesh = buildPlatSelectionMesh(pos, level, height_offset, 0.05)

func get_property_dict() -> Dictionary:
	var dict : Dictionary
	dict["Texture"] = texture 
	
	return dict

const quad_indices = [0, 1, 3, 1, 2, 3] # Magic array 
static func _createPlatQuadMesh(surface_tool : SurfaceTool, wall_vertices : Array, sIndex: int, 
	tex : int, colour : Color) -> void:
	
	# Normal needs to be added before the vertex for some reason (TODO: Clean up)
	var normal = (wall_vertices[2] - wall_vertices[1]).cross(wall_vertices[3] - wall_vertices[1]).normalized()
	
	var texture_float = (tex+1.0)/256
	var texture_scale = WorldTextures.textures[tex].texScale
	
	# Add Vertices
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(wall_vertices[0].x * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
	                            wall_vertices[0].z * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[0])
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(wall_vertices[3].x * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
	                            wall_vertices[3].z * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[3])

	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(wall_vertices[2].x * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
	                            wall_vertices[2].z * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[2])
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(wall_vertices[1].x * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
	                            wall_vertices[1].z * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[1])
	
	# Quad Indices
	for idx in quad_indices:
		surface_tool.add_index(sIndex + idx)

static func buildPlatform(pos : Vector2, level : int, height_offset : float, tex : int, colour : Color,
	is_prototype : bool) -> Mesh:
		
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var height = (level - 1 + height_offset) * WorldConstants.LEVEL_HEIGHT
	var start = Vector2(pos.x - 1, pos.y - 1)
	var end   = Vector2(pos.x + 1, pos.y + 1)
	
	# Calculate wall vertices
	var plat_vertices = []
	plat_vertices.insert(0, Vector3(start.x, height, start.y))
	plat_vertices.insert(1, Vector3(end.x,   height, start.y))
	plat_vertices.insert(2, Vector3(end.x,   height, end.y))
	plat_vertices.insert(3, Vector3(start.x, height, end.y))
	_createPlatQuadMesh(surface_tool, plat_vertices, 0, tex, colour)
	
	# Rearrange vertices for the backwall
	var bVertices = [plat_vertices[3], plat_vertices[2], plat_vertices[1], plat_vertices[0]]
	_createPlatQuadMesh(surface_tool, bVertices, 4, tex, colour)
	
	if is_prototype:
		surface_tool.set_material(WorldTextures.prototype_grass_mat)
	else: 
		surface_tool.set_material(WorldTextures.aTexture_mat)
	
	return surface_tool.commit()

static func buildPlatSelectionMesh(pos : Vector2, level : int, height_offset : float, outlineWidth : float) -> Mesh:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var height = (level - 1 + height_offset) * WorldConstants.LEVEL_HEIGHT
	var start = Vector2(pos.x - 1 - outlineWidth, pos.y - 1 - outlineWidth)
	var end   = Vector2(pos.x + 1 + outlineWidth, pos.y + 1 + outlineWidth)
	
	# Calculate wall vertices
	var plat_vertices = []
	plat_vertices.insert(0, Vector3(start.x, height, start.y))
	plat_vertices.insert(1, Vector3(end.x,   height, start.y))
	plat_vertices.insert(2, Vector3(end.x,   height, end.y))
	plat_vertices.insert(3, Vector3(start.x, height, end.y))
	for i in range(0, 4):
		plat_vertices[i].y = plat_vertices[i].y + 0.02
	_createPlatQuadMesh(surface_tool, plat_vertices, 0, 0, Color(1,1,1))
	
	# Rearrange vertices for the backwall
	var bVertices = [plat_vertices[3], plat_vertices[2], plat_vertices[1], plat_vertices[0]]
	for i in range(0, 4):
		bVertices[i].y = bVertices[i].y - (0.02 * 2)
	_createPlatQuadMesh(surface_tool, bVertices, 4, 0, Color(1,1,1))
	
	surface_tool.set_material(WorldTextures.selection_mat)
	
	return surface_tool.commit()