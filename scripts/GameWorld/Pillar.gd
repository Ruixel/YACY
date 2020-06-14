extends Spatial
const toolType = WorldConstants.Tools.PILLAR

const canPlace = true
const onePerLevel = false
const hasDefaultObject = true

var pos : Vector2
var level : int

var texture : int = 4
var colour := Color(1, 1, 1)

var size : int = 1
var diagonal : bool = false

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
	
	pos = position
	level = lvl 
	
	add_child(mesh)
	add_child(collision_mesh)
	collision_mesh.add_child(collision_shape)

func get_type():
	return "pillar"

func get_level():
	return level

func change_height_value(h : int):
	max_height = max_height_list[h - 1] / 4.0
	min_height = min_height_list[h - 1] / 4.0

func change_texture(index: int):
	texture = index

func change_size(newSize : int):
	size = newSize

func change_colour(newColour : Color):
	colour = newColour

func change_diagonal(isSet : bool):
	diagonal = isSet

func get_property_dict() -> Dictionary:
	var dict : Dictionary = {}
	dict["Texture"] = texture 
	dict["Colour"] = colour
	dict["Height"] = Vector2(min_height, max_height)
	dict["PillarSize"] = size
	dict["Diagonal"] = diagonal
	
	return dict

const dictToObj = {
	"Texture":"texture", 
	"Colour":"colour",
	"PillarSize":"size",
	"Diagonal":"diagonal",
	"Height":"minmaxVector2"
}

var minmaxVector2 : Vector2 = Vector2(1, 0) # DONT WRITE TO THIS
func set_property_dict(dict : Dictionary):
	for prop in dictToObj:
		set(dictToObj[prop], dict[prop])
	
	min_height = minmaxVector2.x
	max_height = minmaxVector2.y

func _genMesh():
	mesh.mesh = buildMesh(level, false)
	collision_shape.shape = mesh.mesh.create_convex_shape()

func selectObj():
	selection_mesh = MeshInstance.new()
	selection_mesh.mesh = mesh.mesh.create_outline(0.05)
	selection_mesh.mesh.surface_set_material(0, WorldTextures.selection_mat)

func genPrototypeMesh(pLevel : int) -> Mesh:
	return buildMesh(pLevel, true)

const size_offset = [0.25, 0.50, 1.00, 1.50, 2.00]
func buildMesh(pLevel : int, is_prototype : bool) -> Mesh:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var minHeight = (pLevel - 1 + max_height) * WorldConstants.LEVEL_HEIGHT - 0.0005
	var maxHeight = (pLevel - 1 + min_height) * WorldConstants.LEVEL_HEIGHT + 0.0005
	
	var quad_vertices = []
	var thickness  = size_offset[size-1] / 5.0
	
	if not diagonal:
		var pillar_min = Vector2(pos.x + thickness, pos.y)
		var pillar_max = Vector2(pos.x - thickness, pos.y)
		
		# Calculate wall vertices
		var t = Vector3(0, 0, thickness)
		quad_vertices.insert(0, Vector3(pillar_max.x, maxHeight, pillar_max.y) - t)
		quad_vertices.insert(1, Vector3(pillar_min.x, maxHeight, pillar_min.y) - t)
		quad_vertices.insert(2, Vector3(pillar_min.x, minHeight, pillar_min.y) - t)
		quad_vertices.insert(3, Vector3(pillar_max.x, minHeight, pillar_max.y) - t)
		
		quad_vertices.insert(4, Vector3(pillar_max.x, maxHeight, pillar_max.y) + t)
		quad_vertices.insert(5, Vector3(pillar_min.x, maxHeight, pillar_min.y) + t)
		quad_vertices.insert(6, Vector3(pillar_min.x, minHeight, pillar_min.y) + t)
		quad_vertices.insert(7, Vector3(pillar_max.x, minHeight, pillar_max.y) + t)
	else:
		thickness = sqrt(2*pow(thickness, 2))
		var pillar_min = Vector2(pos.x + thickness, pos.y + thickness)
		var pillar_max = Vector2(pos.x - thickness, pos.y - thickness)
		
		quad_vertices.insert(0, Vector3(pos.x, maxHeight, pillar_max.y) )
		quad_vertices.insert(1, Vector3(pillar_min.x, maxHeight, pos.y) )
		quad_vertices.insert(2, Vector3(pillar_min.x, minHeight, pos.y) )
		quad_vertices.insert(3, Vector3(pos.x, minHeight, pillar_max.y) )
		
		quad_vertices.insert(4, Vector3(pillar_max.x, maxHeight, pos.y) )
		quad_vertices.insert(5, Vector3(pos.x, maxHeight, pillar_min.y) )
		quad_vertices.insert(6, Vector3(pos.x, minHeight, pillar_min.y) )
		quad_vertices.insert(7, Vector3(pillar_max.x, minHeight, pos.y) )
	
	_createWallQuadMesh(quad_vertices[5], quad_vertices[6], quad_vertices[7], quad_vertices[4], surface_tool, 0)
	_createWallQuadMesh(quad_vertices[0], quad_vertices[3], quad_vertices[2], quad_vertices[1], surface_tool, 4)
	
	_createPlatQuadMesh(surface_tool, [quad_vertices[2], quad_vertices[3], quad_vertices[7], quad_vertices[6]], 8, texture, colour)
	_createPlatQuadMesh(surface_tool, [quad_vertices[1], quad_vertices[5], quad_vertices[4], quad_vertices[0]], 12, texture, colour)
	
	_createWallQuadMesh(quad_vertices[4], quad_vertices[7], quad_vertices[3], quad_vertices[0], surface_tool, 16)
	_createWallQuadMesh(quad_vertices[1], quad_vertices[2], quad_vertices[6], quad_vertices[5], surface_tool, 20)
	
	if is_prototype:
		surface_tool.set_material(WorldTextures.aTexturePrototype_mat)
	else: 
		surface_tool.set_material(WorldTextures.getWallMaterial(texture))
	return surface_tool.commit()

var quad_indices = [0, 1, 2, 0, 2, 3] # Magic array 
func _createWallQuadMesh(v1 : Vector3, v2 : Vector3, v3 : Vector3, v4 : Vector3, 
	surface_tool : SurfaceTool, sIndex: int) -> void:

	# Normal needs to be added before the vertex for some reason (TODO: Clean up)
	var normal = (v3 - v2).cross(v1 - v2).normalized()
	
	# Texture constants
	var wall_length = sqrt(pow(v3.z - v1.z, 2) + pow(v3.x - v1.x, 2))
	# Godot does not allow for custom vertex attributes, use the alpha in Color() for storing texture index
	var texture_float = (texture+1.0)/256
	var texture_scale = WorldTextures.textures[texture].texScale
	
	# Add Vertices
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(0 * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								v3.y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(v1)
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(wall_length * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								v3.y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(v4)
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(wall_length * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								v1.y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(v3)
	
	surface_tool.add_color(Color(colour.r, colour.g, colour.b, texture_float))
	surface_tool.add_uv(Vector2(0 * texture_scale.x * WorldConstants.TEXTURE_SIZE,  
								v1.y * texture_scale.y * WorldConstants.TEXTURE_SIZE))
	surface_tool.add_normal(normal)
	surface_tool.add_vertex(v2)
	
	# Quad Indices
	for idx in quad_indices:
		surface_tool.add_index(sIndex + idx)

func _createPlatQuadMesh(surface_tool : SurfaceTool, wall_vertices : Array, sIndex: int, 
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
	
	min_height = minmaxVector2.x
	max_height = minmaxVector2.y
