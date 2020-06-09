extends Spatial
const toolType = WorldConstants.Tools.GROUND

const canPlace = false
const onePerLevel = true
const hasDefaultObject = false

var vertices : Array
var level : int
var isVisible : bool

var floor_texture : int = 1
var floor_colour := Color(1, 1, 1)
var ceil_texture : int = 2
var ceil_colour := Color(1, 1, 1)

var mesh : MeshInstance
var selection_mesh : MeshInstance
var collision_mesh : StaticBody
var collision_shape : CollisionShape

func _init(lvl : int):
	mesh = MeshInstance.new()
	collision_mesh = StaticBody.new()
	collision_shape = CollisionShape.new()
	
	#vertices.insert(0, Vector2(0, 80))
	#vertices.insert(1, Vector2(80, 80))
	#vertices.insert(2, Vector2(80, 0))
	#vertices.insert(3, Vector2(0, 0))
	
	vertices.insert(0, Vector2(0, 10))
	vertices.insert(1, Vector2(10, 10))
	vertices.insert(2, Vector2(10, 0))
	vertices.insert(3, Vector2(0, 0))
	
	level = lvl 
	isVisible = false
	
	add_child(mesh)
	add_child(collision_mesh)
	collision_mesh.add_child(collision_shape)

func get_level():
	return level

func change_texture(index: int):
	floor_texture = index

func change_visible(vis: bool):
	isVisible = vis

func change_colour(newColour : Color):
	floor_colour = newColour

func change_vertex(newVertexInfo : Array):
	vertices[newVertexInfo[1]] = newVertexInfo[0]

func _genMesh():
	if isVisible:
		mesh.mesh = buildFloor()
		collision_shape.shape = mesh.mesh.create_convex_shape()
	else:
		mesh.mesh = null
		collision_shape.shape = null

func selectObj():
	pass
	#selection_mesh = MeshInstance.new()
	#selection_mesh.mesh = buildPlatSelectionMesh(pos, level, size, height_offset, 0.05)

func get_property_dict() -> Dictionary:
	var dict : Dictionary = {}
	dict["Visible"] = isVisible
	dict["Texture"] = floor_texture 
	dict["Colour"] = floor_colour
	
	return dict

func set_property_dict(dict : Dictionary):
	isVisible = dict["Visible"]
	floor_texture = dict["Texture"]
	floor_colour = dict["Colour"]

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

const tri_indices = [0, 1, 2] # Magic array 
static func _createPlatTriMesh(surface_tool : SurfaceTool, tri_vertices : Array, sIndex: int, 
	tex : int, colour : Color) -> void:
	
	# Normal needs to be added before the vertex for some reason (TODO: Clean up)
	var normal = (tri_vertices[2] - tri_vertices[0]).cross(tri_vertices[1] - tri_vertices[0]).normalized()
	
	var texture_float = (tex+1.0)/256
	var texture_scale = WorldTextures.textures[tex].texScale
	
	# Add Vertices
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(tri_vertices[0].x * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								tri_vertices[0].z * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(tri_vertices[0])
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(tri_vertices[1].x * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								tri_vertices[1].z * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(tri_vertices[1])

	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(tri_vertices[2].x * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								tri_vertices[2].z * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(tri_vertices[2])
	
	# Quad Indices
	for idx in tri_indices:
		surface_tool.add_index(sIndex + idx)

func buildFloor() -> Mesh:
	var gen = get_node("/root/Spatial/FloorGenerator")
	return gen.generateFloorMesh(vertices, level, floor_texture, 
		floor_colour, ceil_texture, ceil_colour, HoleManager.get_holes(level))

#	var wc = get_node("/root/WorldConstants")
#	print(wc.get_path())
#	print(wc.get("WORLD_HEIGHT"))
#
#	var surface_tool = SurfaceTool.new()
#	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
#
#	var height = (level - 1) * WorldConstants.LEVEL_HEIGHT
#
#	# Set colour to white if not using the colour wall
#	var floor_meshColor = floor_colour
#	if floor_texture != WorldTextures.TextureID.COLOR:
#		floor_meshColor = Color(1,1,1)
#
#	var ceil_meshColor = ceil_colour
#	if ceil_texture != WorldTextures.TextureID.COLOR:
#		ceil_meshColor = Color(1,1,1)
#
#	# Calculate wall vertices
#	var plat_vertices = []
#	plat_vertices.insert(0, Vector3(vertices[0].x, height, vertices[0].y))
#	plat_vertices.insert(1, Vector3(vertices[1].x, height, vertices[1].y))
#	plat_vertices.insert(2, Vector3(vertices[2].x, height, vertices[2].y))
#	plat_vertices.insert(3, Vector3(vertices[3].x, height, vertices[3].y))
#
#	_createPlatQuadMesh(surface_tool, plat_vertices, 0, floor_texture, floor_meshColor)
#
#	# Rearrange vertices for the backwall
#	var bVertices = [plat_vertices[3], plat_vertices[2], plat_vertices[1], plat_vertices[0]]
#	_createPlatQuadMesh(surface_tool, bVertices, 4, ceil_texture, ceil_meshColor)
#
#	surface_tool.set_material(WorldTextures.getWallMaterial(floor_texture))
#	return surface_tool.commit()
