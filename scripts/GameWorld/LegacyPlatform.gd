extends Spatial
const toolType = WorldConstants.Tools.PLATFORM

const canPlace = true
const onePerLevel = false
const hasDefaultObject = true

var pos : Vector2
var level : int

var texture : int = 5
var colour := Color(1, 1, 1)

var size : int = 1
const size_list = [2, 4, 8, 16]

var height_offset : float = 0.0
const h_offset_list = [0, 1, 2, 3]

var platShape = WorldConstants.PlatShape.QUAD

var mesh : MeshInstance
var selection_mesh : MeshInstance
var collision_mesh : StaticBody
var collision_shape : CollisionShape

func _init(position : Vector2, lvl : int):
	mesh = MeshInstance.new()
	collision_mesh = StaticBody.new()
	collision_shape = CollisionShape.new()
	
	pos = position
	level = lvl 
	
	add_child(mesh)
	add_child(collision_mesh)
	collision_mesh.add_child(collision_shape)

func get_level():
	return level

func change_height_value(h : int):
	if h <= 4:
		height_offset = h_offset_list[h-1] / 4.0

func change_texture(index: int):
	texture = index

func change_colour(newColour : Color):
	colour = newColour

func change_size(newSize : int):
	size = newSize

func change_platShape(newShape):
	platShape = newShape 

func _genMesh():
	mesh.mesh = buildPlatform(pos, level, height_offset, texture, colour, size, platShape, false)
	collision_shape.shape = mesh.mesh.create_convex_shape()

func genPrototypeMesh(pLevel : int) -> Mesh:
	return buildPlatform(Vector2(0,0), pLevel, height_offset, texture, colour, size, platShape, true)

func selectObj():
	selection_mesh = MeshInstance.new()
	selection_mesh.mesh = buildPlatSelectionMesh(pos, level, size, height_offset, 0.05)

func get_property_dict() -> Dictionary:
	var dict : Dictionary = {}
	dict["Texture"] = texture 
	dict["Colour"] = colour
	dict["Height"] = height_offset
	dict["Size"] = size
	dict["PlatShape"] = platShape
	
	return dict

const dictToObj = {
	"Texture":"texture", 
	"Colour":"colour",
	"Height":"height_offset",
	"Size":"size",
	"PlatShape":"platShape"
}
func set_property_dict(dict : Dictionary):
	for prop in dictToObj:
		set(dictToObj[prop], dict[prop])

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

static func buildPlatform(pos : Vector2, level : int, height_offset : float, tex : int, colour : Color,
	size : int, pShape, is_prototype : bool) -> Mesh:
		
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var height = (level - 1 + height_offset + 0.003) * WorldConstants.LEVEL_HEIGHT
	
	var halfSize = size_list[size-1] / 2
	var start = Vector2(pos.x - halfSize, pos.y - halfSize)
	var end   = Vector2(pos.x + halfSize, pos.y + halfSize)
	
	# Set colour to white if not using the colour wall
	var meshColor = colour
	if tex != WorldTextures.TextureID.COLOR:
		meshColor = Color(1,1,1)
	
	# Calculate wall vertices
	var plat_vertices = []
	if pShape != WorldConstants.PlatShape.DIAMOND:
		plat_vertices.insert(0, Vector3(start.x, height, start.y))
		plat_vertices.insert(1, Vector3(end.x,   height, start.y))
		plat_vertices.insert(2, Vector3(end.x,   height, end.y))
		plat_vertices.insert(3, Vector3(start.x, height, end.y))
	else:
		plat_vertices.insert(0, Vector3(pos.x, height, start.y))
		plat_vertices.insert(1, Vector3(end.x,   height, pos.y))
		plat_vertices.insert(2, Vector3(pos.x,   height, end.y))
		plat_vertices.insert(3, Vector3(start.x, height, pos.y))
	
	if pShape == WorldConstants.PlatShape.QUAD or pShape == WorldConstants.PlatShape.DIAMOND:
		_createPlatQuadMesh(surface_tool, plat_vertices, 0, tex, meshColor)
		
		# Rearrange vertices for the backwall
		var bVertices = [plat_vertices[3], plat_vertices[2], plat_vertices[1], plat_vertices[0]]
		_createPlatQuadMesh(surface_tool, bVertices, 4, tex, meshColor)
		
	elif pShape == WorldConstants.PlatShape.TRI_BR:
		_createPlatTriMesh(surface_tool, [plat_vertices[2], plat_vertices[3], plat_vertices[0]], 0, tex, meshColor)
		_createPlatTriMesh(surface_tool, [plat_vertices[0], plat_vertices[3], plat_vertices[2]], 3, tex, meshColor)
	elif pShape == WorldConstants.PlatShape.TRI_TR:
		_createPlatTriMesh(surface_tool, [plat_vertices[1], plat_vertices[2], plat_vertices[3]], 0, tex, meshColor)
		_createPlatTriMesh(surface_tool, [plat_vertices[1], plat_vertices[2], plat_vertices[3]], 3, tex, meshColor)
	elif pShape == WorldConstants.PlatShape.TRI_TL:
		_createPlatTriMesh(surface_tool, [plat_vertices[0], plat_vertices[1], plat_vertices[2]], 0, tex, meshColor)
		_createPlatTriMesh(surface_tool, [plat_vertices[2], plat_vertices[1], plat_vertices[0]], 3, tex, meshColor)
	elif pShape == WorldConstants.PlatShape.TRI_BL:
		_createPlatTriMesh(surface_tool, [plat_vertices[3], plat_vertices[0], plat_vertices[1]], 0, tex, meshColor)
		_createPlatTriMesh(surface_tool, [plat_vertices[1], plat_vertices[0], plat_vertices[3]], 3, tex, meshColor)
	
	if is_prototype:
		surface_tool.set_material(WorldTextures.aTexturePrototype_mat)
	else: 
		surface_tool.set_material(WorldTextures.getWallMaterial(tex))
	
	return surface_tool.commit()

static func buildPlatSelectionMesh(pos : Vector2, level : int, size : int, height_offset : float, outlineWidth : float) -> Mesh:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var height = (level - 1 + height_offset + 0.003) * WorldConstants.LEVEL_HEIGHT
	
	var halfSize = size_list[size-1] / 2
	var start = Vector2(pos.x - halfSize - outlineWidth, pos.y - halfSize - outlineWidth)
	var end   = Vector2(pos.x + halfSize + outlineWidth, pos.y + halfSize + outlineWidth)
	
	# Calculate wall vertices
	var plat_vertices = []
	plat_vertices.insert(0, Vector3(start.x, height, start.y))
	plat_vertices.insert(1, Vector3(end.x,   height, start.y))
	plat_vertices.insert(2, Vector3(end.x,   height, end.y))
	plat_vertices.insert(3, Vector3(start.x, height, end.y))
	for i in range(0, 4):
		plat_vertices[i].y = plat_vertices[i].y + 0.035
	_createPlatQuadMesh(surface_tool, plat_vertices, 0, 0, Color(1,1,1))
	
	# Rearrange vertices for the backwall
	var bVertices = [plat_vertices[3], plat_vertices[2], plat_vertices[1], plat_vertices[0]]
	for i in range(0, 4):
		bVertices[i].y = bVertices[i].y - (0.02 * 2)
	_createPlatQuadMesh(surface_tool, bVertices, 4, 0, Color(1,1,1))
	
	surface_tool.set_material(WorldTextures.selection_mat)
	
	return surface_tool.commit()

func JSON_serialise(default_dict) -> Dictionary:
	# Only add values that differ from the default
	var dict = get_property_dict()
	for k in dict.keys():
		if dict[k] == default_dict[k]:
			dict.erase(k)
	
	# Add unique variables
	dict["Lvl"] = level
	dict["Pos"] = pos
	
	# Colours should be serialised into a smaller format
	if dict.has("Colour"):
		dict["Colour"] = dict["Colour"].to_html()
	
	return dict

func JSON_deserialise(dict):
	for k in dict.keys():
		if dictToObj.has(k) :
			var property = self.get(dictToObj.get(k)) 
			self.set(dictToObj.get(k), Utils.json2obj(dict[k], property))
