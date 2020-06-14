extends Spatial
const toolType = WorldConstants.Tools.WALL

const canPlace = true
const onePerLevel = false
const hasDefaultObject = true

var start : Vector2
var end : Vector2 = Vector2(-1, -1) # Invalid vector
var level : int

var texture : int = 3
var colour := Color(1, 1, 1)

var max_height : float = 1.0
var min_height : float = 0.0
const max_height_list = [4, 3, 2, 1, 2, 3, 4, 4, 4, 3]
const min_height_list = [0, 0, 0, 0, 1, 2, 3, 2, 1, 1]

var wallShape = WorldConstants.WallShape.FULLWALL

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

func get_type():
	return "wall"

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

func change_wallShape(newShape):
	wallShape = newShape

func _genMesh():
	mesh.mesh = buildWall(start, end, level, min_height, max_height, texture, colour, wallShape)
	collision_shape.shape = mesh.mesh.create_convex_shape()

func selectObj():
	selection_mesh = MeshInstance.new()
	selection_mesh.mesh = buildWallSelectionMesh(start, end, level, min_height, max_height, 0.05)

func get_property_dict() -> Dictionary:
	var dict : Dictionary= {}
	dict["Texture"] = texture 
	dict["Colour"] = colour
	dict["Height"] = Vector2(min_height, max_height)
	dict["WallShape"] = wallShape
	
	return dict

const dictToObj = {
	"Texture":"texture", 
	"Colour":"colour",
	"WallShape":"wallShape",
	"Height":"minmaxVector2"
}

var minmaxVector2 : Vector2 = Vector2(1, 0) # DONT WRITE TO THIS
func set_property_dict(dict : Dictionary):
	for prop in dictToObj:
		set(dictToObj[prop], dict[prop])
	
	min_height = minmaxVector2.x
	max_height = minmaxVector2.y

# Static Mesh Creation Functions

# Single face
const quad_indices = [0, 1, 3, 1, 2, 3] # Magic array 
static func _createWallQuadMesh(surface_tool : SurfaceTool, wall_vertices : Array, sIndex: int, 
	tex : int, colour : Color) -> void:
	
	# Normal needs to be added before the vertex for some reason (TODO: Clean up)
	var normal = (wall_vertices[2] - wall_vertices[1]).cross(wall_vertices[0] - wall_vertices[1]).normalized()
	
	# Texture constants
	var wall_length = sqrt(pow(wall_vertices[2].z - wall_vertices[0].z, 2) + pow(wall_vertices[2].x - wall_vertices[0].x, 2))
	# Godot does not allow for custom vertex attributes, use the alpha in Color() for storing texture index
	var texture_float = (tex+1.0)/256
	var texture_scale = WorldTextures.textures[tex].texScale
	
	# Add Vertices
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(0 * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								wall_vertices[2].y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[0])
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(wall_length * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								wall_vertices[2].y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[3])
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(wall_length * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								wall_vertices[0].y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[2])
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(0 * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								wall_vertices[0].y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[1])
	
	# Quad Indices
	for idx in quad_indices:
		surface_tool.add_index(sIndex + idx)

const tri_indices = [0, 1, 2] # Magic array 
static func _createWallTriMesh(surface_tool : SurfaceTool, wall_vertices : Array, sIndex: int, 
	tex : int, colour : Color, uv_invert : bool = false) -> void:

	# Normal needs to be added before the vertex for some reason (TODO: Clean up)
	var normal = (wall_vertices[2] - wall_vertices[0]).cross(wall_vertices[1] - wall_vertices[0]).normalized()
	
	# Texture constants
	var wall_length = sqrt(pow(wall_vertices[2].z - wall_vertices[0].z, 2) + pow(wall_vertices[2].x - wall_vertices[0].x, 2))
	# Godot does not allow for custom vertex attributes, use the alpha in Color() for storing texture index
	var texture_float = (tex+1.0)/256
	var texture_scale = WorldTextures.textures[tex].texScale
	
	if uv_invert:
		wall_length = -wall_length
	
	# Add Vertices
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(wall_length * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								-wall_vertices[0].y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[0])
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(wall_length * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								-wall_vertices[1].y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[1])
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(0 * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								-wall_vertices[2].y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(wall_vertices[2])
	
	# Quad Indices
	for idx in tri_indices:
		surface_tool.add_index(sIndex + idx)

# Build Mesh
static func buildWall(start : Vector2, end : Vector2, level : int, min_height : float, 
	max_height : float, tex : int, colour : Color, wallShape) -> Mesh:
	
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
	
	# Calculate wall vertices
	var wall_vertices = []
	wall_vertices.insert(0, Vector3(start.x, maxHeight, start.y))
	wall_vertices.insert(1, Vector3(start.x, minHeight, start.y))
	wall_vertices.insert(2, Vector3(end.x, minHeight, end.y))
	wall_vertices.insert(3, Vector3(end.x, maxHeight, end.y))
	
	if wallShape == WorldConstants.WallShape.FULLWALL:
		_createWallQuadMesh(surface_tool, wall_vertices, 0, tex, meshColor)
		
		# Rearrange vertices for the backwall
		var bVertices = [wall_vertices[3], wall_vertices[2], wall_vertices[1], wall_vertices[0]]
		_createWallQuadMesh(surface_tool, bVertices, 4, tex, meshColor)
		
	elif wallShape == WorldConstants.WallShape.HALFWALLBOTTOM:
		_createWallTriMesh(surface_tool, wall_vertices, 0, tex, meshColor, false)
		
		var bVertices = [wall_vertices[1], wall_vertices[0], wall_vertices[2]]
		_createWallTriMesh(surface_tool, bVertices, 3, tex, meshColor, true)
	
	elif wallShape == WorldConstants.WallShape.HALFWALLTOP:
		var fVertices = [wall_vertices[0], wall_vertices[1], wall_vertices[3]]
		_createWallTriMesh(surface_tool, fVertices, 0, tex, meshColor, false)
		
		var bVertices = [wall_vertices[1], wall_vertices[0], wall_vertices[3]]
		_createWallTriMesh(surface_tool, bVertices, 3, tex, meshColor, true)
	
	elif wallShape == WorldConstants.WallShape.QCIRCLEWALL:
		var steps = 5
		var idx = 0
		
		var dir = (end - start) / steps
		var h_delta = (maxHeight - minHeight) / steps
		var curHeight = minHeight
		for i in range(0,steps):
			end = start + dir 
			var w_vertices = []
			w_vertices.insert(0, Vector3(start.x, curHeight, start.y))
			w_vertices.insert(1, Vector3(start.x, minHeight, start.y))
			w_vertices.insert(2, Vector3(end.x, minHeight, end.y))
			w_vertices.insert(3, Vector3(end.x, curHeight + h_delta, end.y))
			
			_createWallQuadMesh(surface_tool, w_vertices, idx, tex, meshColor)
		
			# Rearrange vertices for the backwall
			var bVertices = [w_vertices[3], w_vertices[2], w_vertices[1], w_vertices[0]]
			_createWallQuadMesh(surface_tool, bVertices, idx+4, tex, meshColor)
			
			idx = idx + 8
			curHeight = curHeight + h_delta
			start = end
	
	surface_tool.set_material(WorldTextures.getWallMaterial(tex))
	return surface_tool.commit()

func buildWallSelectionMesh(start : Vector2, end : Vector2, level : int, min_height : float, max_height : float,
	outlineWidth : float) -> Mesh:
	
	# Only create mesh for valid walls
	if end.x == -1:
		return Mesh.new()
		
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var minHeight = (level - 1 + min_height) * WorldConstants.LEVEL_HEIGHT - outlineWidth
	var maxHeight = (level - 1 + max_height) * WorldConstants.LEVEL_HEIGHT + outlineWidth
	
	# Get Vector 
	var wall_vec = (end - start).normalized()
	end   = end   + wall_vec * outlineWidth
	start = start - wall_vec * outlineWidth
	
	var normal_vec = Vector3(wall_vec.x, 0, wall_vec.y).cross(Vector3(0, 1, 0))
	
	var wall_vertices = []
	wall_vertices.insert(0, Vector3(start.x, maxHeight, start.y))
	wall_vertices.insert(1, Vector3(start.x, minHeight, start.y))
	wall_vertices.insert(2, Vector3(end.x, minHeight, end.y))
	wall_vertices.insert(3, Vector3(end.x, maxHeight, end.y))
	
	var new_vertices = []
	for vertex in wall_vertices:
		new_vertices.append(vertex - normal_vec * 0.02)
	
	_createWallQuadMesh(surface_tool, new_vertices, 0, 1, Color(1,1,1))
	
	var bVertices = [wall_vertices[3], wall_vertices[2], wall_vertices[1], wall_vertices[0]]
	var new_bVertices = []
	for vertex in bVertices:
		new_bVertices.append(vertex + normal_vec * 0.02)
	_createWallQuadMesh(surface_tool, new_bVertices, 4, 1, Color(1,1,1))
	
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
