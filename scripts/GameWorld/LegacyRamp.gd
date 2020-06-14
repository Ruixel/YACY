extends Spatial
const toolType = WorldConstants.Tools.RAMP

const canPlace = true
const onePerLevel = false
const hasDefaultObject = true

var start : Vector2
var end : Vector2 = Vector2(-1, -1) # Invalid vector
var level : int

var texture : int = 5
var colour := Color(1, 1, 1)

var max_height : float = 1.0
var min_height : float = 0.0
const max_height_list = [4, 3, 2, 1, 2, 3, 4, 4, 4, 3]
const min_height_list = [0, 0, 0, 0, 1, 2, 3, 2, 1, 1]

var mesh : MeshInstance
var selection_mesh : MeshInstance 
var collision_mesh : StaticBody
var collision_shape : CollisionShape

func _init(position : Vector2, lvl : int):
	mesh = MeshInstance.new()
	collision_mesh = StaticBody.new()
	collision_shape = CollisionShape.new()
	
	start = position
	level = lvl
	
	add_child(mesh)
	add_child(collision_mesh)
	collision_mesh.add_child(collision_shape)

func get_level():
	return level

func change_end_pos(pos : Vector2):
	end = pos

func change_height_value(h : int):
	max_height = max_height_list[h - 1] / 4.0
	min_height = min_height_list[h - 1] / 4.0

func change_texture(index: int):
	texture = index

func change_colour(newColour : Color):
	colour = newColour

func _genMesh():
	mesh.mesh = buildRamp(start, end, level, min_height, max_height, texture, colour)
	collision_shape.shape = mesh.mesh.create_convex_shape()

func selectObj():
	selection_mesh = MeshInstance.new()
	selection_mesh.mesh = buildRampSelectionMesh(start, end, level, min_height, max_height, 0.05)


func get_property_dict() -> Dictionary:
	var dict : Dictionary= {}
	dict["Texture"] = texture 
	dict["Colour"] = colour
	dict["Height"] = Vector2(min_height, max_height)
	
	return dict

const dictToObj = {
	"Texture":"texture", 
	"Colour":"colour",
	"Height":"minmaxVector2"
}

var minmaxVector2 : Vector2 = Vector2(1, 0) # DONT WRITE TO THIS
func set_property_dict(dict : Dictionary):
	for prop in dictToObj:
		set(dictToObj[prop], dict[prop])
	
	min_height = minmaxVector2.x
	max_height = minmaxVector2.y

# Build Mesh
static func buildRamp(start : Vector2, end : Vector2, level : int, min_height : float, 
	max_height : float, tex : int, colour : Color) -> Mesh:
	
	# Only create mesh for valid walls
	if end.x == -1:
		return Mesh.new()
	
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var minHeight = (level - 1 + min_height) * WorldConstants.LEVEL_HEIGHT
	var maxHeight = (level - 1 + max_height) * WorldConstants.LEVEL_HEIGHT
	
	# Set colour to white if not using the colour wall
	var meshColor = colour
	if tex != WorldTextures.TextureID.COLOR:
		meshColor = Color(1,1,1)
	
	# Vertices
	var line = end - start
	var widthDir = (end - start).tangent().normalized()
	var halfWidth = ((sqrt(8)-2)*abs(sin(2*atan2(line.y, line.x))) + 2) / 2.0
	var width = widthDir * halfWidth
	
	var s1 = start - width
	var s2 = start + width
	var e1 = end - width
	var e2 = end + width
	
	# Calculate ramp vertices
	var quad_vertices = []
	quad_vertices.insert(0, Vector3(s1.x, minHeight, s1.y))
	quad_vertices.insert(1, Vector3(e1.x, maxHeight, e1.y))
	quad_vertices.insert(2, Vector3(e2.x, maxHeight, e2.y))
	quad_vertices.insert(3, Vector3(s2.x, minHeight, s2.y))
	
	_createPlatQuadMesh(surface_tool, quad_vertices, 0, tex, meshColor, halfWidth * 2.0)
	
	# Rearrange vertices for the backwall
	var bVertices = [quad_vertices[3], quad_vertices[2], quad_vertices[1], quad_vertices[0]]
	_createPlatQuadMesh(surface_tool, bVertices, 4, tex, meshColor, halfWidth * 2.0)
	
	surface_tool.set_material(WorldTextures.getWallMaterial(tex))
	return surface_tool.commit()

const quad_indices = [0, 1, 3, 1, 2, 3] # Magic array 
static func _createPlatQuadMesh(surface_tool : SurfaceTool, quad_vertices : Array, sIndex: int, 
	tex : int, colour : Color, width : float) -> void:
	
	# Normal needs to be added before the vertex for some reason (TODO: Clean up)
	var normal = (quad_vertices[2] - quad_vertices[1]).cross(quad_vertices[3] - quad_vertices[1]).normalized()
	var ramp_length = quad_vertices[0].distance_to(quad_vertices[1])
	#print(ramp_length)
	
	var texture_float = (tex+1.0)/256
	var texture_scale = WorldTextures.textures[tex].texScale
	
	# Add Vertices
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(0 * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								0 * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(quad_vertices[0])
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(width * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								0 * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(quad_vertices[3])

	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(width * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								ramp_length * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(quad_vertices[2])
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(0 * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								ramp_length * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(quad_vertices[1])
	
	# Quad Indices
	for idx in quad_indices:
		surface_tool.add_index(sIndex + idx)

static func buildRampSelectionMesh(start : Vector2, end : Vector2, level : int, min_height : float, 
	max_height : float, outlineWidth : float) -> Mesh:
	
	# Only create mesh for valid walls
	if end.x == -1:
		return Mesh.new()
	
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var minHeight = (level - 1 + min_height) * WorldConstants.LEVEL_HEIGHT 
	var maxHeight = (level - 1 + max_height) * WorldConstants.LEVEL_HEIGHT 
	
	# Vertices
	var line = end - start
	var widthDir = (end - start).tangent().normalized()
	var halfWidth = ((sqrt(8)-2)*abs(sin(2*atan2(line.y, line.x))) + 2) / 2.0
	var width = widthDir * (halfWidth + outlineWidth)
	
	var s1 = start - width 
	var s2 = start + width 
	var e1 = end - width
	var e2 = end + width 
	
	# Calculate ramp vertices
	var quad_vertices = []
	quad_vertices.insert(0, Vector3(s1.x, minHeight, s1.y))
	quad_vertices.insert(1, Vector3(e1.x, maxHeight, e1.y))
	quad_vertices.insert(2, Vector3(e2.x, maxHeight, e2.y))
	quad_vertices.insert(3, Vector3(s2.x, minHeight, s2.y))
	for i in range(0, 4):
		quad_vertices[i].y = quad_vertices[i].y - 0.02
	_createPlatQuadMesh(surface_tool, quad_vertices, 0, 1, Color(0,0,0), halfWidth * 2.0)
	
	# Rearrange vertices for the backwall
	var bVertices = [quad_vertices[3], quad_vertices[2], quad_vertices[1], quad_vertices[0]]
	for i in range(0, 4):
		bVertices[i].y = bVertices[i].y + (0.02 * 2)
	_createPlatQuadMesh(surface_tool, bVertices, 4, 1, Color(0,0,0), halfWidth * 2.0)
	
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
	dict["Pos"] = start
	dict["End"] = end
	
	# Colours should be serialised into a smaller format
	if dict.has("Colour"):
		dict["Colour"] = dict["Colour"].to_html()
	
	return dict

func JSON_deserialise(dict):
	for k in dict.keys():
		if dictToObj.has(k) :
			var property = self.get(dictToObj.get(k)) 
			self.set(dictToObj.get(k), Utils.json2obj(dict[k], property))
	
	min_height = minmaxVector2.x
	max_height = minmaxVector2.y
	
	end = Utils.json2obj(dict["End"], end)
